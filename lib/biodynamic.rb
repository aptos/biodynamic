require 'date'
require 'json'

include Math

class Biodynamic
  # Known new moon, January 6, 2000
  NM = 2451550.1

  # Synodic Month
  SM = 29.530588853

  # Anomalystic Month
  AM = 27.554549878

  # Tropical Month
  TM = 27.321582241

  attr_accessor :phase_names, :zodiac_names, :sidereal
  def initialize
    @phase_names = ["new", "waxing_crescent","first_quarter","waxing_gibbous","full","waning_gibbous","last_quarter","waning_crescent"]
    @zodiac_names = ['Aries','Taurus','Gemini','Cancer','Leo','Virgo','Libra','Scorpio','Sagittarius','Capricorn','Aquarius','Pisces']
  end

  def normalize v
    v -= v.floor
    v += 1 if v < 0
    return v
  end

  def moon_phase date
    # offset from last new moon
    p = (date.jd - NM) % SM

    # find the octet by adding a 16th of a month, then divide by months
    phase = ((p + (SM/16))*8/SM).floor
    phase = 0 if phase == 8

    return @phase_names[phase]
  end

  def moon_sign date
    d = (date.jd - NM)/SM
    rad = normalize(d) * 2 * PI
    # Distance
    dp = normalize((date.jd - 2451562.2) / AM) * 2 * PI

    # Ecliptic longitude
    rp = normalize((date.jd - 2451555.8) / TM)
    lo = 360 * rp + 6.3 * sin(dp) + 1.3 * sin(2 * rad - dp) + 0.7 * sin(2 * rad);

    # map longitude into 12 Astrological Sign quadrants
    sign_quadrant = (lo*12/360.0).floor
    sign_quadrant = 0 if sign_quadrant == 12

    return @zodiac_names[sign_quadrant]
  end

  def influence zodiac
    if ['Aries','Leo','Sagittarius'].include? zodiac
      return 'fruit'
    elsif ['Taurus', 'Virgo', 'Capricorn'].include? zodiac
      return 'root'
    elsif ['Gemini','Libra', 'Aquarius'].include? zodiac
      return 'flower'
    elsif ['Cancer', 'Scorpio', 'Pisces'].include? zodiac
      return 'leaf'
    end
    return 'unknown'
  end

  def calendar start_date=Date.today, count=30
    data = Hash.new{ |h,k| h[k] = Hash.new(&h.default_proc) }
    (0..count).each do |d|
      day = start_date + d
      data[day][:moon_phase] = self.moon_phase day
      zodiac = self.moon_sign day
      data[day][:moon_sign] = zodiac
      data[day][:influence] = self.influence zodiac
    end

    return data
  end

end

bd = Biodynamic.new
cal = bd.calendar

puts JSON cal