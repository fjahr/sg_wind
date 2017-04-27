class ObservationsController < ApplicationController
  before_action :set_observation, only: [:show, :edit, :update, :destroy]

  # GET /observations
  # GET /observations.json
  def index
    @observations = Observation.order("created_at").last(96)
  end

  # GET /observations/1
  # GET /observations/1.json
  def show
    render text: params[:id]

  end

  # GET /observations/new
  def new
    response = Faraday.get('http://www.weather.gov.sg/weather-currentobservations-wind/')
    page = Nokogiri::HTML(response.body)
    time_element = page.css('span.date-obs')
    time = time_element.text.gsub("Observations at ", "")

    wind_elements = page.css('span.sgr')
    winds = {}

    wind_elements.each do |elem|
      location = elem.attributes["data-content"].value.scan(/<strong>.*<\/strong>/).last.gsub('<strong>', '').gsub('</strong>', '')
      speed = elem.text.to_f
      direction = elem.children[1].attributes["src"].value.scan(/sm-.*.png$/).first.gsub("sm-", "").gsub(".png", "")
      winds[location.parameterize] = {speed: speed, direction: direction}
    end

    @observation = Observation.new(time: time, data: winds)
    @observation.save

    render status: 200, text: "success"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_observation
      @observation = Observation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def observation_params
      params.require(:observation).permit(:data)
    end
end
