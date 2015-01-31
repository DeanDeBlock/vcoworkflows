require_relative 'constants'
require_relative 'workflow'
require_relative 'workflowservice'
require 'json'

module VcoWorkflows
  # WorkflowToken is used for workflow execution results, and contains as much
  # data on the given workflow execution instance as vCO can provide.
  class WorkflowToken
    attr_reader :id
    attr_reader :workflow_id
    attr_reader :name
    attr_reader :state
    attr_reader :href
    attr_reader :start_date
    attr_reader :end_date
    attr_reader :started_by
    attr_reader :current_item_name
    attr_reader :current_item_state
    attr_reader :content_exception
    attr_reader :global_state
    attr_reader :input_parameters
    attr_reader :output_parameters
    attr_reader :json_content

    # rubocop:disable CyclomaticComplexity, PerceivedComplexity, MethodLength, LineLength

    # Create a new workflow token
    # @param [VcoWorkflows::WorkflowService] workflow_service Workflow service to use
    # @param [String] workflow_id GUID of the workflow
    # @param [String] execution_id GUID of execution
    # @return [VcoWorkflows::WorkflowToken]
    def initialize(workflow_service, workflow_id, execution_id)
      @service = workflow_service
      @workflow_id = workflow_id
      @json_content = @service.get_execution(workflow_id, execution_id)

      token = JSON.parse(@json_content)

      @id                 = token.key?('id')                        ? token['id']                        : nil
      @name               = token.key?('name')                      ? token['name']                      : nil
      @state              = token.key?('state')                     ? token['state']                     : nil
      @href               = token.key?('href')                      ? token['href']                      : nil
      @start_date         = token.key?('start-date')                ? token['start-date']                : nil
      @end_date           = token.key?('end-date')                  ? token['end-date']                  : nil
      @started_by         = token.key?('started-by')                ? token['started-by']                : nil
      @current_item_name  = token.key?('current-item-display-name') ? token['current-item-display-name'] : nil
      @current_item_state = token.key?('current-item-state')        ? token['current-item-state']        : nil
      @global_state       = token.key?('global-state')              ? token['global-state']              : nil
      @content_exception  = token.key?('content-exeption')          ? token['content-exception']         : nil

      if token.key?('input-parameters')
        @input_parameters = VcoWorkflows::Workflow.parse_parameters(token['input-parameters'])
      else
        @input_parameters = {}
      end

      if token.key?('output-parameters')
        @output_parameters = VcoWorkflows::Workflow.parse_parameters(token['output-parameters'])
      else
        @output_parameters = {}
      end
    end
    # rubocop:enable CyclomaticComplexity, PerceivedComplexity, MethodLength, LineLength

    # Is the workflow execution still alive?
    # @return [Boolean]
    def alive?
      running? || waiting?
    end

    # Is the workflow actively running?
    # @return [Boolean]
    def running?
      state.eql?('running')
    end

    # Is the workflow in a waiting state?
    # @return [Boolean]
    def waiting?
      state.match(/waiting/).nil? ? false : true
    end

    # rubocop:disable MethodLength, LineLength

    # Convert this object to a string representation
    # @return [String]
    def to_s
      string =  "Execution ID:      #{@id}\n"
      string << "Name:              #{@name}\n"
      string << "Workflow ID:       #{@workflow_id}\n"
      string << "State:             #{@state}\n"
      string << "Start Date:        #{Time.at(@start_date / 1000)}\n"
      string << "End Date:          #{end_date.nil? ? '' : Time.at(@end_date / 1000)}\n"
      string << "Started By:        #{@started_by}\n"
      string << "Content Exception: #{@content_exception}\n" unless @content_exception.nil?
      string << "\nInput Parameters:\n"
      @input_parameters.each_value { |wf_param| string << " #{wf_param}" if wf_param.set? } if @input_parameters.size > 0
      string << "\nOutput Parameters:" << "\n"
      @output_parameters.each_value { |wf_param| string << " #{wf_param}" } if @output_parameters.size > 0
      string
    end
    # rubocop:enable MethodLength, LineLength

    # Convert this object to a JSON document (string)
    # @return [String] JSON representation of the workflow token
    def to_json
      JSON.pretty_generate(JSON.parse(@json_content))
    end
  end
end
