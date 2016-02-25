class GithubWebhooksController < ApplicationController
  
	include GithubWebhook::Processor
  # require 'net/ssh'
  # require 'net/ssh/shell'

	# skip_before_filter :verify_authenticity_token, :only => [:index]

	def github_push(payload)
    TestGraderWorker.perform_async(payload)
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
