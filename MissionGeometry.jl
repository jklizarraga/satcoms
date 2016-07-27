module MissionGeometry __precompile__()

  export centralbodycentralangle, nadiranlge, centralbodyangularradius, centralbodycentralangleattruehorizon, slantrange

  function centralbodycentralangle(; elevation::Float64 = NaN, orbitAltitude::Float64 = NaN, centralBodyRadius::Float64 = 6371e3, angularUnits = :Degrees)
    if angularUnits == :Degrees
      return 90   - elevation - asind(cosd(elevation) * (centralBodyRadius/(centralBodyRadius + orbitAltitude)))
    elseif andgularUnits == :Radians
      return pi/2 - elevation - asin (cos (elevation) * (centralBodyRadius/(centralBodyRadius + orbitAltitude)))
    end
  end

  function nadiranlge(;elevation::Float64 = NaN, orbitAltitude::Float64 = NaN, centralBodyRadius::Float64 = 6371e3, angularUnits = :Degrees)
    if angularUnits == :Degrees
      return asind(cosd(elevation) * (centralBodyRadius/(centralBodyRadius + orbitAltitude)))
    elseif andgularUnits == :Radians
      return asin (cos (elevation) * (centralBodyRadius/(centralBodyRadius + orbitAltitude)))
    end
  end

  function centralbodyangularradius(; orbitAltitude::Float64 = NaN, centralBodyRadius::Float64 = 6371e3, angularUnits = :Degrees)
    if angularUnits == :Degrees
      return asind((centralBodyRadius/(centralBodyRadius + orbitAltitude)))
    elseif andgularUnits == :Radians
      return asin ((centralBodyRadius/(centralBodyRadius + orbitAltitude)))
    end
  end

  function centralbodycentralangleattruehorizon(; orbitAltitude::Float64 = NaN, centralBodyRadius::Float64 = 6371e3, angularUnits = :Degrees)
    if angularUnits == :Degrees
      return acosd((centralBodyRadius/(centralBodyRadius + orbitAltitude)))
    elseif andgularUnits == :Radians
      return acos ((centralBodyRadius/(centralBodyRadius + orbitAltitude)))
    end
  end

  function slantrange(; elevation::Float64 = NaN, orbitAltitude::Float64 = NaN, centralBodyRadius::Float64 = 6371e3, angularUnits = :Degrees)
    if angularUnits == :Degrees
      return centralBodyRadius * (sqrt((1 + orbitAltitude/centralBodyRadius)^2 - (cosd(elevation)^2)) - sind(elevation))
    elseif andgularUnits == :Radians
      return centralBodyRadius * (sqrt((1 + orbitAltitude/centralBodyRadius)^2 - (cos (elevation)^2)) - sin (elevation))
    end
  end

end

