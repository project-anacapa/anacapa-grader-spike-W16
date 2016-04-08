class GithubWebhooksController < ApplicationController
  
	include GithubWebhook::Processor
  # require 'net/ssh'
  # require 'net/ssh/shell'

	# skip_before_filter :verify_authenticity_token, :only => [:index]

	def github_push(payload)

    pushType = payload["repository"]["full_name"].split("/")[1].split("-")[0]
    if pushType == "assignment"
      TestGraderWorker.perform_async(payload)
    end

    org = payload["repository"]["organization"]
    repo = payload["repository"]["name"]
    repo_array = repo.split("-")

    project_name    = repo_array[0]
    type            = repo_array[1]
    user            = repo_array[2]

    expected_repo   = "#{org}/#{project_name}-expected" 
    student_repo    = "#{org}/#{project_name}-#{user}"
    grade_repo      = "#{org}/#{project_name}-grade"
    #results_repo    = "#{org}/#{project_name}-results-#{type}"

    organization = Organization.new.github_client
    case type
    when "grader"
        if not organization.repository?(expected_repo)
            organization.create_repository(
                "#{project_name}-expected", organization: org, auto_init: true)
            end
    when "expected"
    when "grade"
    #when "results"
    #    if not organization.repository?(grade_repo)
    #        organization.create_repository(
    #            "#{project_name}-grade", organization: org, auto_init: true)
    #    end
    else
        if not organization.repository?(grade_repo)
            organization.create_repository(
                "#{project_name}-grade", organization: org, auto_init: true)
        end
    end
	end

	def github_create(payload)
		# Rails.application.config.logger.info "THERE WAS A CREATE: #{payload}"
	end

	def webhook_secret(payload)
		"topsecret"
    # ENV["WEBHOOK_SECRET"]
	end

	def webhooks
		puts "Went to page!"
	end
end
