require 'gorillib/receiver_model'

class TmpRecord
  include Gorillib::ReceiverModel
  rcvr_accessor :average,            Float, :replace => { 9999.9 => 'missing' }
  rcvr_accessor :observations,       Integer
  rcvr_accessor :minimum,            Float, :replace => { 9999.9 => 'missing' }
  rcvr_accessor :maximum,            Float, :replace => { 9999.9 => 'missing' }
end

class DewRecord
  include Gorillib::ReceiverModel
  rcvr_accessor :average,            Float, :replace => { 9999.9 => 'missing' }
  rcvr_accessor :observations,       Integer
end

class SLPRecord
  include Gorillib::ReceiverModel
  rcvr_accessor :average,            Float, :replace => { 9999.9 => 'missing' }
  rcvr_accessor :observations,       Integer
end

class STPRecord
  include Gorillib::ReceiverModel
  rcvr_accessor :average,            Float, :replace => { 9999.9 => 'missing' }
  rcvr_accessor :observations,       Integer
end

class VisRecord
  include Gorillib::ReceiverModel
  rcvr_accessor :average,            Float, :replace => { 999.9 => 'missing' }
  rcvr_accessor :observations,       Integer
end

class WndRecord
  include Gorillib::ReceiverModel
  rcvr_accessor :average,            Float, :replace => { 999.9 => 'missing' }
  rcvr_accessor :observations,       Integer
  rcvr_accessor :maximum_sustained,  Float, :replace => { 999.9 => 'missing' }
  rcvr_accessor :maximum_gust,       Float, :replace => { 999.9 => 'missing' }
end

class CndRecord
  include Gorillib::ReceiverModel
  rcvr_accessor :fog,                String, :replace => { '1' => true, '0' => false }
  rcvr_accessor :rain,               String, :replace => { '1' => true, '0' => false }
  rcvr_accessor :snow,               String, :replace => { '1' => true, '0' => false }
  rcvr_accessor :hail,               String, :replace => { '1' => true, '0' => false }
  rcvr_accessor :thunder,            String, :replace => { '1' => true, '0' => false }
  rcvr_accessor :tornado,            String, :replace => { '1' => true, '0' => false }
end

class WeatherRecord
  include Gorillib::ReceiverModel
  rcvr_accessor :station_number,     String
  rcvr_accessor :wban_number,        String
  rcvr_accessor :year_month,         Integer
  rcvr_accessor :day,                Integer
  rcvr_accessor :precipitation,      Float, :replace => { 99.99 => 0.0 }
  rcvr_accessor :snow_depth,         Float, :replace => { 999.9 => 0.0 }
  rcvr_accessor :temperature,        TmpRecord
  rcvr_accessor :dew_point,          DewRecord
  rcvr_accessor :sea_level_pressure, SLPRecord
  rcvr_accessor :station_pressure,   STPRecord
  rcvr_accessor :visibility,         VisRecord
  rcvr_accessor :wind_speed,         WndRecord
  rcvr_accessor :conditions,         CndRecord

  def to_array
    [
      station_number + '-' + wban_number,
      year_month,
      day,
      precipitation,
      snow_depth,
      temperature.average,
      temperature.observations,
      temperature.maximum,
      temperature.minimum,
      dew_point.average,
      dew_point.observations,
      sea_level_pressure.average,
      sea_level_pressure.observations,
      station_pressure.average,
      station_pressure.observations,
      visibility.average,
      visibility.observations,
      wind_speed.average,
      wind_speed.observations,
      wind_speed.maximum_sustained,
      wind_speed.maximum_gust,
      conditions.fog,
      conditions.rain,
      conditions.snow,
      conditions.hail,
      conditions.thunder,
      conditions.tornado
    ]
  end
end

