# frozen_string_literal: true

class ReviewsController < ApplicationController
  def create
    @product = Product.find(params[:product_id])
    @review = @product.reviews.build(review_params)
    @review.user_id = current_user.id
    @reviewed_product = @review.product
    if @review.save
      @reviewed_product.create_notification_review!(current_user, @reviewed_product.id)
      ave_rate = Review.where(product_id: @reviewed_product.id).average(:rate)
      @product.update(ave_rate: ave_rate)
      redirect_back(fallback_location: root_path)
    else
      flash[:danger] = @review.errors.full_messages
      redirect_to controller: 'products', action: 'show', id: @product.id
    end
  end

  private

    def review_params
      params.require(:review).permit(:text, :rate).merge(product_id: params[:product_id], user_id: current_user.id)
    end
end
