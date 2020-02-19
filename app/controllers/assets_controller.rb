class AssetsController < ApplicationController
  before_action :set_user
  before_action :set_asset, only: %i[show update destroy]

  # GET /assets
  def index
    @assets = @user.assets

    @assets.each do |asset|
      asset[:total_cost] = asset.total_cost
      asset[:yearly_cost] = asset.total_cost(
        financial_year: params[:financial_year]
      )
    end

    render json: @assets
  end

  # GET /assets/1
  def show
    render json: @asset
  end

  # POST /assets
  def create
    @asset = @user.assets.build(asset_params)

    if @asset.save
      render json: @asset, status: :created
    else
      render json: @asset.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /assets/1
  def update
    if @asset.update(asset_params)
      render json: @asset
    else
      render json: @asset.errors, status: :unprocessable_entity
    end
  end

  # DELETE /assets/1
  def destroy
    @asset.destroy
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_asset
    @asset = @user.assets.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def asset_params
    params.require(:asset).permit(:title, :value)
  end
end
