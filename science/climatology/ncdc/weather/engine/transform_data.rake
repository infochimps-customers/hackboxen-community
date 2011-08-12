task :transform => ['transform:stations', 'transform:observations']

namespace :transform do

  desc 'Extract weather station metadata from the NCDC weather stations "inventory" file'
  task :stations do
    # open the inventory file

    # read each line with a FormattedFlatRecordizer
    # received by a RawWeatherObservation.receive()

    # map RawWeatherStation to Science::Climatology::Ncdc::WeatherStation
    # (an auto_klass created from the target ICSS)

    # Save out each WeatherStation
    # (the logic and format of this are no concern of this file)

  end

  desc 'Extract weather observations from the NCDC "GSOD" directory tree. This will be tens of thousands of files and many GB.'
  task :observations do
    # for each file in the ripd/.../gsod directory

    # read each line with a FormattedFlatRecordizer
    # received by a RawWeatherObservation.receive()

    # map RawWeatherObservation to Science::Climatology::Ncdc::WeatherObservation
    # (an auto_klass created from the target ICSS)

    # Save out each RawWeatherObservation
    # (the logic and format of this are no concern of this file)

  end

end


desc 'Final form of ICSS'
task :generate_icss do

  # note the output files, add as data_asset's
  # (this should be a one-liner)

  # emit the ICSS

  # note that if steps above aren't run, we may have a gappy icss (eg
end
