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
      winds[location] = {speed: speed, direction: direction}
    end

    @observation = Observation.new(time: time, data: winds)
    @observation.save

    render status: 200, text: "success"
  end

  # GET /observations/1/edit
  def edit
  end

  # POST /observations
  # POST /observations.json
  def create
    @observation = Observation.new(observation_params)

    respond_to do |format|
      if @observation.save
        format.html { redirect_to @observation, notice: 'Observation was successfully created.' }
        format.json { render :show, status: :created, location: @observation }
      else
        format.html { render :new }
        format.json { render json: @observation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /observations/1
  # PATCH/PUT /observations/1.json
  def update
    respond_to do |format|
      if @observation.update(observation_params)
        format.html { redirect_to @observation, notice: 'Observation was successfully updated.' }
        format.json { render :show, status: :ok, location: @observation }
      else
        format.html { render :edit }
        format.json { render json: @observation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /observations/1
  # DELETE /observations/1.json
  def destroy
    @observation.destroy
    respond_to do |format|
      format.html { redirect_to observations_url, notice: 'Observation was successfully destroyed.' }
      format.json { head :no_content }
    end
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
