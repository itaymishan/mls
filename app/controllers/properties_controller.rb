class PropertiesController < ApplicationController

  def index
    @q = Property.ransack(params[:q])
    @properties = @q.result(distinct: true)
    @properties.order(print_date: :desc, street_name: :desc)
    @res = @properties.last(100)   
  end
 
  # def show    
  #   @properties = Property.find(params[:id])
  # end

  def show    
    @properties = Property.find(params[:id]).compareables
  end

  def show
    @properties = Property.find(params[:id])
  end

end