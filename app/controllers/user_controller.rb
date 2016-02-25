class UserController < ApplicationController
      def index
      	  client = Octokit::Client.new(access_token: "12b70ab44d9c507bdee5246bc0b926d79c979116") 
          @organizations = client.organization_memberships
      end
end
