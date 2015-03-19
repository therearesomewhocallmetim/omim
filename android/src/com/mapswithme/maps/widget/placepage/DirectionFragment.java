package com.mapswithme.maps.widget.placepage;

import android.location.Location;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.DialogFragment;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.mapswithme.maps.Framework;
import com.mapswithme.maps.R;
import com.mapswithme.maps.bookmarks.data.DistanceAndAzimut;
import com.mapswithme.maps.bookmarks.data.MapObject;
import com.mapswithme.maps.location.LocationHelper;
import com.mapswithme.maps.widget.ArrowView;
import com.mapswithme.util.LocationUtils;

public class DirectionFragment extends DialogFragment implements LocationHelper.LocationListener
{
  private ArrowView mAvDirection;
  private TextView mTvTitle;
  private TextView mTvSubtitle;
  private TextView mTvDistance;

  private MapObject mMapObject;

  @Override
  public void onCreate(Bundle savedInstanceState)
  {
    super.onCreate(savedInstanceState);
    setStyle(DialogFragment.STYLE_NORMAL, R.style.MwmMain_Dialog_DialogFragment_Fullscreen);
  }

  @Override
  public void onSaveInstanceState(Bundle outState)
  {
    super.onSaveInstanceState(outState);
  }

  @Override
  public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState)
  {
    final View root = inflater.inflate(R.layout.fragment_direction, container, false);
    root.setOnTouchListener(new View.OnTouchListener()
    {
      @Override
      public boolean onTouch(View v, MotionEvent event)
      {
        dismiss();
        return false;
      }
    });
    initViews(root);
    return root;
  }

  private void initViews(View root)
  {
    mAvDirection = (ArrowView) root.findViewById(R.id.av__direction);
    mTvTitle = (TextView) root.findViewById(R.id.tv__title);
    mTvSubtitle = (TextView) root.findViewById(R.id.tv__subtitle);
    mTvDistance = (TextView) root.findViewById(R.id.tv__straight_distance);
  }

  public void setMapObject(MapObject object)
  {
    mMapObject = object;
    refreshViews();
  }

  private void refreshViews()
  {
    if (mMapObject != null && isResumed())
    {
      mTvTitle.setText(mMapObject.getName());
      mTvSubtitle.setText(mMapObject.getPoiTypeName());
    }
  }


  @Override
  public void onResume()
  {
    super.onResume();
    LocationHelper.INSTANCE.addLocationListener(this);
    refreshViews();
  }

  @Override
  public void onPause()
  {
    super.onPause();
    LocationHelper.INSTANCE.removeLocationListener(this);
  }

  @Override
  public void onLocationUpdated(Location location)
  {
    if (mMapObject != null)
    {
      final DistanceAndAzimut distanceAndAzimuth = Framework.nativeGetDistanceAndAzimutFromLatLon(mMapObject.getLat(),
          mMapObject.getLon(), location.getLatitude(), location.getLongitude(), 0.0);
      mTvDistance.setText(distanceAndAzimuth.getDistance());
    }
  }

  @Override
  public void onCompassUpdated(long time, double magneticNorth, double trueNorth, double accuracy)
  {
    final Location last = LocationHelper.INSTANCE.getLastLocation();
    if (last == null || mMapObject == null)
      return;

    final int rotation = getActivity().getWindowManager().getDefaultDisplay().getRotation();
    magneticNorth = LocationUtils.correctCompassAngle(rotation, magneticNorth);
    trueNorth = LocationUtils.correctCompassAngle(rotation, trueNorth);
    final double north = (trueNorth >= 0.0) ? trueNorth : magneticNorth;

    final DistanceAndAzimut da = Framework.nativeGetDistanceAndAzimutFromLatLon(
        mMapObject.getLat(), mMapObject.getLon(),
        last.getLatitude(), last.getLongitude(), north);

    if (da.getAthimuth() >= 0)
      mAvDirection.setAzimut(da.getAthimuth());
  }

  @Override
  public void onLocationError(int errorCode)
  {

  }
}
