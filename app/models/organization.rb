class Organization < ActiveRecord::Base
    def github_client
        @github_client = Octokit::Client.new(
            access_token: ENV['ACCESS_TOKEN']
            )
    end
end
