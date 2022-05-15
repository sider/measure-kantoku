FROM ruby:3.1.2-slim

RUN groupadd collector && useradd -m -g collector collector
USER collector:collector
WORKDIR /home/collector/scripts
COPY --chown=collector:collector Gemfile Gemfile.lock collector.rb sampled_issue.rb run.sh ./
RUN bundle install && chmod u+x ./run.sh

ENTRYPOINT ["/home/collector/scripts/run.sh"]
