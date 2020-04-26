class QuizsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :set_quiz, only: %i[update]

  # POST /quizs
  def create
    @quiz = Quiz.new(quiz_params)

    if @quiz.save
      render json: @quiz, status: :created
    else
      render json: @quiz.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /quizs/1
  def update
    if @quiz.update(quiz_params)
      render json: @quiz
    else
      render json: @quiz.errors, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_quiz
    @quiz = Quiz.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def quiz_params
    params.require(:quiz).permit(
      :name,
      :planned_before,
      :score
    )
  end
end
