class CategoriesController < ApplicationController
  before_action :set_user
  before_action :set_category, only: %i[show update destroy]

  # GET /categories
  def index
    render json: grouped_categories
  end

  # GET /categories/1
  def show
    render json: @category
  end

  # POST /categories
  def create
    @category = @user.categories.build(category_params)

    if @category.save
      render json: {
        id: @category.to_param, title: @category.title, type: @category.type
      }, status: :created
    else
      render json: @category.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /categories/1
  def update
    if @category.update(category_params)
      @category[:benefit] = @category.benefit
      @category[:asset] = @category.asset
      render json: @category
    else
      render json: @category.errors, status: :unprocessable_entity
    end
  end

  # DELETE /categories/1
  def destroy
    @category.destroy
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_category
    @category = @user.categories.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def category_params
    params.require(:category).permit(:type, :title, :benefit_id, :asset_id)
  end

  def grouped_categories
    Category::SUPER_CATEGORY.values
    results = Category::SUPER_CATEGORY.values.map { |e| [e, []] }.to_h
    @user.categories.each do |category|
      results[category.type] ||= []
      results[category.type].push(category_hash(category))
    end
    results
  end

  def category_hash(category)
    {
      id: category.to_param,
      title: category.title,
      type: category.type,
      goal: category.goal,
      benefit: category.benefit,
      benefit_id: category.benefit.try(:id)&.to_s,
      asset_id: category.asset.try(:id)&.to_s,
      asset: category.asset
    }
  end
end
