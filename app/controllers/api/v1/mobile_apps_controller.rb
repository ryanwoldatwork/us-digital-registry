class Api::V1::MobileAppsController < Api::ApiController
	swagger_controller :mobile_apps, "Government Mobile Apps"

	swagger_api :index do
		summary "Fetches all mobile apps"
    notes "This lists all active mobile apps.  It accepts parameters to perform basic search."
    param :query, :q, :string, :optional, "String to compare to the name & short description of the mobile apps."
    param :query, :agencies, :ids, :optional, "Comma seperated list of agency ids"
    param :query, :tags, :ids, :optional, "Comma seperated list of tag ids"
    param :query, :page_size, :integer, :optional, "Number of results per page"
    param :query, :page, :integer, :optional, "Page number"
    response :ok, "Success"
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable		
		response :not_found
	end

	PAGE_SIZE=25
	DEFAULT_PAGE=1

	def index
		@mobile_apps = MobileApp.joins(:agencies, :official_tags)
    if params[:q]
      @mobile_apps = @mobile_apps.where("name LIKE ? or short_description LIKE ? or long_description LIKE ?", 
      	"%#{params[:q]}%", "%#{params[:q]}%", "%#{params[:q]}%")
    end
    if params[:agencies]
      @mobile_apps = @mobile_apps.where("agencies.id" =>params[:agencies].split(","))
    end
    if params[:tags]
      @mobile_apps = @mobile_apps.where("official_tags.id" => params[:tags].split(","))
    end
		@mobile_apps = @mobile_apps.page(params[:page] || DEFAULT_PAGE).per(params[:page_size] || PAGE_SIZE)
		respond_to do |format|
			format.json { render "index" }
		end		
	end

	swagger_api :show do
		summary "Fetches a single mobile app item"
		notes "This returns an mobile app based on an ID."
		param :path, :id, :integer, :required, "ID of the mobile app"
		response :ok, "Success" 
		response :not_acceptable, "The request you made is not available"
		response :requested_range_not_satisfiable
		response :not_found
	end
	def show
		@mobile_app =  MobileApp.find(params[:id])
		respond_to do |format|
			format.json { render "show" }
		end		
	end
end
