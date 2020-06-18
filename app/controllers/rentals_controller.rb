class RentalsController < JSONAPI::ResourceController
  def index
  	@rentals = Rental.all
  end

  def show
  	@rental = Rental.find(params[:id])
  	respond_to do |format|
  	  format.json { render :json => @rental.to_json }
  	end
  end

  def new
    @rental = Rental.new
  end

  def create
  	@rental = Rental.new(rental_params)
  	@rental.save
  end

  def update
  	@rental = Rental.find(params[:id])
  	@rental.update(rental_params)
  end

  def destroy
  	@rental = Rental.find(params[:id])
  	@rental.destroy
  end

  private
    def rental_params
      params.permit(:title, :owner, :city, :category, :image, :bedrooms, :description)
    end
end