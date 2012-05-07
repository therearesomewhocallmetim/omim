#pragma once

#include "../geometry/rect2d.hpp"

#include "../std/string.hpp"


namespace url_scheme
{
  struct Info
  {
    double m_lat, m_lon, m_zoom;

    static double EmptyValue() { return -1000.0; }

    bool IsValid() const
    {
      return (m_lat != EmptyValue() && m_lon != EmptyValue());
    }

    void Reset();

    Info()
    {
      Reset();
    }

    m2::RectD GetViewport() const;
  };

  void ParseURL(string const & s, Info & info);
}
