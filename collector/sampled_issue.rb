class SampledIssue
  def initialize (issue_id:, issue_number:, title:, author:, assignees:, labels:, state:, comments:, created_at:, updated_at:, closed_at:, sampled_at:)
    @data = self.method(__callee__).parameters.map do |param|
      [param[1], binding.local_variable_get(param[1])]
    end.to_h
  end

  def self.create_from_issue(issue, sampled_time)
    self.new(
      issue_id: issue[:id],
      issue_number: issue[:number],
      title: issue[:title],
      author: issue[:user]&.[](:login),
      assignees: issue[:assignees]&.map { |assignee| assignee[:login] },
      labels: issue[:labels]&.map { |label| label[:name] },
      state: issue[:state],
      comments: issue[:comments],
      created_at: issue[:created_at]&.utc&.iso8601,
      updated_at: issue[:updated_at]&.utc&.iso8601,
      closed_at: issue[:closed_at]&.utc&.iso8601,
      sampled_at: sampled_time.utc&.iso8601
    )
  end

  def to_h
    @data
  end
end

