require 'elasticsearch'
require 'octokit'
require 'faraday'
require 'json'
require './sampled_issue.rb'
require 'dotenv'

# load parameters from .env file (development only)
Dotenv.load

# parameters
ACCESS_TOKEN = ENV['GITHUB_ACCESS_TOKEN'].freeze
TARGET_REPO_OWNER = ENV['GITHUB_TARGET_REPOSITORY_OWNER'].freeze
TARGET_REPO_NAME = ENV['GITHUB_TARGET_REPOSITORY_NAME'].freeze
MAX_ISSUE = ENV['GITHUB_MAX_ISSUE'].freeze
ES_INDEX_NAME = 'sideci_1000'.freeze

# utils
def repository_reference
  "#{TARGET_REPO_OWNER}/#{TARGET_REPO_NAME}"
end

def es_index_name
  "issues_#{repository_reference}"
end

def github_client
  @github_client ||= Octokit::Client.new(access_token: ACCESS_TOKEN, per_page: 100)
end

def es_client
  @es_client ||= Elasticsearch::Client.new(url: 'http://localhost:9200')
end

def kibana_client
  @kibana_client ||= Faraday.new(url: 'http://localhost:5601/api/', headers: {'Content-Type' => 'application/json', 'kbn-xsrf' => 'true'})
end

# core logics
def sample_issues
  issues = []
  sampled_time = Time.now
  res = github_client.list_issues(repository_reference, state: 'all', sort: 'created')
  loop do
    res.each do |issue|
      next unless issue.pull_request.nil?
      issues << SampledIssue.create_from_issue(issue, sampled_time)
    end
    break if issues.length > MAX_ISSUE
    break if github_client.last_response.rels[:next].nil?
    res = github_client.get(github_client.last_response.rels[:next].href)
  end
  
  issues
end

def get_repository_search(query)
  github_client.search_issues(query, page: 0, per_page: 1)
end

def get_repository_metrics
  {
    issue: {
      open: get_repository_search("repo:#{repository_name} is:issue state:open")[:total_count],
      closed: get_repository_search("repo:#{repository_name} is:issue state:closed")[:total_count]
    },
    pull_request: {
      open: get_repository_search("repo:#{repository_name} is:pr state:open")[:total_count],
      closed: get_repository_search("repo:#{repository_name} is:pr state:closed")[:total_count]
    }
  }
end

def put_issues_to_es(issues)
  # create index
  es_client.indices.create(index: es_index_name) unless es_client.indices.exists?(index: es_index_name)

  # create or update
  issues.each do |issue|
    # search existing records
    res = es_client.search(index: es_index_name, q: "issue_id: #{issue.to_h[:issue_id]}")

    # index or update
    if res['hits']['total']['value'] == 0
      es_client.index(index: es_index_name, body: issue.to_h)
    else
      res['hits']['hits'].each do |record|
        es_client.index(index: es_index_name, id: record['_id'], body: issue.to_h)
      end
    end
  end

  # create index pattern for kibana
res = kibana_client.get("index_patterns/index_pattern/#{es_index_name}")

kibana_client.post('index_patterns/index_pattern',{
                  index_pattern: {
                    title: es_index_name,
                    id: es_index_name,
                    timeFieldName: 'created_at'
                  }
                }.to_json) if res.status == 404
end


# main

if $0 == __FILE__
  puts("----start----")
  issues = sample_issues
  puts("issue fetch completed: #{sample_issues.length} issues")
  put_issues_to_es(issues)
  puts("----end----")
end

