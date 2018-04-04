class ObservationsController < ApplicationController

  def index
    @observations = Observation.order("created_at").last(144).reverse
  end

  def show
    @station = params[:id]
    @observations = Observation.order("created_at").last(144)

    speeds = @observations.map do |o|
      if o.data[@station] && o.data[@station]
        [o.created_at, o.data[@station]["speed"]]
      end
    end
    @speeds = speeds.compact

    dir_res = []

    @observations.map do |o|
      if o.data[@station] && o.data[@station]
        time = o.created_at
        dir = o.data[@station]["direction"]

        if dir_res.last && (dir_res.last[0] == dir)
          last = dir_res.pop

          dir_res.push([dir, last[1], time])
        elsif dir_res.last
          dir_res.push([dir, dir_res.last[2], time])
        else
          dir_res.push([dir, time, time])
        end
      end
    end

    @directions = dir_res
  end

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

    # if winds["east-coast-parkway"][:speed] >= 20 && (Notification.last.nil? || (Notification.last.created_at < 6.hours.ago))
    #   Notification.new(station: "east-coast-parkway").save
    #   Subscriber.notify_all
    # end
    #
    Observation.where('created_at < ?', 1.day.ago).destroy_all

    render status: 200, text: "success"
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def observation_params
      params.require(:observation).permit(:data)
    end
end
