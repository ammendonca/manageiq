class MiddlewareServerController < ApplicationController
  include EmsCommon
  include ContainersCommonMixin
  include MiddlewareCommonMixin

  before_action :check_privileges
  before_action :get_session_data
  after_action :cleanup_action
  after_action :set_session_data

  OPERATIONS = {
    :middleware_server_reload => {:op   => :reload_middleware_server,
                                  :hawk => N_('Not reloading Hawkular server'),
                                  :msg  => N_('Reload initiated for selected server(s)')
    },
    :middleware_server_stop   => {:op   => :stop_middleware_server,
                                  :hawk => N_('Not stopping Hawkular server'),
                                  :msg  => N_('Stop initiated for selected server(s)')
    },
    :middleware_add_deployment => {:op   => :add_middleware_deployment,
                                  :hawk => N_('Not deploying to Hawkular server'),
                                  :msg  => N_('Deployment initiated for selected server(s)')
    }
  }.freeze

  def add_deployment
    puts "\n\n@@@@@@@@@@@@@@@@@@@@@@@@@ hello add_deployment @@@@@@@@@@@@@@@@@@@@@@@@@@@\n\n"
    params.each do |paramy|
      puts "#{paramy} ==> #{params[paramy]}"
    end
    selected_servers = identify_selected_servers
    selected_servers = "3" #hardcoded.. fixme

    puts "selected_servers"
    puts selected_servers

    puts "OPERATIONS.fetch(:middleware_add_deployment)"
    puts OPERATIONS.fetch(:middleware_add_deployment)

    data = {
      "file_data" => params["file"],
      "file_name" => params["file"].original_filename
    }

    run_server_operation(OPERATIONS.fetch(:middleware_add_deployment), selected_servers, data, true)

    render :update do |page|
      page << javascript_prologue
      page.replace("flash_msg_div", :partial => "layouts/flash_msg")
    end

    puts "\n\n@@@@@@@@@@@@@@@@@@@@@@@@@ gubye add_deployment @@@@@@@@@@@@@@@@@@@@@@@@@@@\n\n"
  end

  def show
    clear_topology_breadcrumb
    @display = params[:display] || "main" unless control_selected?
    @lastaction = "show"
    @showtype = "main"
    @record = identify_record(params[:id], ManageIQ::Providers::Hawkular::MiddlewareManager::MiddlewareServer)

    if @display == 'middleware_datasources'
      show_container_display(@record, 'middleware_datasource', MiddlewareDatasource)
    elsif @display == 'middleware_deployments'
      show_container_display(@record, 'middleware_deployment', MiddlewareDeployment)
    else
      show_container(@record, controller_name, display_name)
    end
  end

  def listicon_image(item, _view)
    icon = item.decorate.try(:listicon_image)
    "svg/#{icon}.svg"
  end

  def button
    selected_operation = params[:pressed].to_sym

    if OPERATIONS.key?(selected_operation)
      selected_servers = identify_selected_servers
      puts "SEL SERVER"
      puts selected_servers
      run_server_operation(OPERATIONS.fetch(selected_operation), selected_servers, nil, false)

      render :update do |page|
        page << javascript_prologue
        page.replace("flash_msg_div", :partial => "layouts/flash_msg")
      end
    else
      super
    end
  end

  private ############################

  # Identify the selected servers. When we got the call from the
  # single server page, we need to look at :id, otherwise from
  # the list of servers we need to query :miq_grid_checks
  def identify_selected_servers
    items = params[:miq_grid_checks]
    return items unless items.nil? || items.empty?

    params[:id]
  end

  def run_server_operation(operation_info, items, data, force)
    if items.nil?
      add_flash(_("No servers selected"))
      return
    end

    operation_triggered = false
    items.split(/,/).each do |item|
      mw_server = identify_record item
      if !force && mw_server.product == 'Hawkular'
        add_flash(operation_info.fetch(:hawk))
      else
        trigger_mw_operation operation_info.fetch(:op), mw_server, data
        operation_triggered = true
      end
    end
    add_flash(operation_info.fetch(:msg)) if operation_triggered
  end

  def trigger_mw_operation(operation, mw_server, data)
    puts "triggering mw op[#{operation}] @ mw_server[#{mw_server.to_s}]"
    mw_manager = mw_server.ext_management_system
    puts "mw manager"
    puts mw_manager

    op = mw_manager.public_method operation
    puts "op"
    puts op

    op.call(mw_server.ems_ref,data)
  end
end
