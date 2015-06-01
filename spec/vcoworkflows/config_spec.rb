require_relative '../spec_helper.rb'
require 'vcoworkflows'

# rubocop:disable LineLength

describe VcoWorkflows::VcoSession, 'VcoSession' do
  before(:each) do
    @uri = 'https://vcoserver.example.com:8281'
    @username = 'johndoe'
    @password = 's3cr3t'
  end
end
