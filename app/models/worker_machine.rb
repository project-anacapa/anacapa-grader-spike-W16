class WorkerMachine < ActiveRecord::Base

	attr_reader :host
	attr_reader :port
	attr_reader :user
	attr_reader :privateKey
	attr_reader :isIdle

	def initialize(host, port, user, privateKey)
		@host = host
		@port = port
		@user = user
		@privateKey = privateKey
		@isIdle = true
	end

	def self.getTestWorkerMachine()
		WorkerMachine.new(h, p, u, pk)
	end

	private
	def self.h
		return "dagwood.cs.ucsb.edu"
	end

	def self.p
		return 22
	end

	def self.u
		return "submit2"
	end

	def self.pk
		# key.rb was not pushed because it contains a private
		# key and an email address for CSIL and github. In order to 
		# run the code, create a new class called key and implement
		# the following methods:
		# 	def self.key()
		# 	def self.graderEmail()
		
		return Key.key()
	end
end
