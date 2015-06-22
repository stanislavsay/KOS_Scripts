Set tVal to 0.
Set targetSpeed to 0.
Stage.
Lock Steering to heading(90,90) + R(0,0,270).
Lock Throttle to tVal.
Lock ShipPos to Ship:GeoPosition.
Set VAB to -74.618738.
Set Pad to -74.55756229.
 
Until Alt:Radar > 120
{
        Set tVal to 1.3 * (ship:mass*9.81)/ship:maxthrust.
}
Set Yaw to 5.
Set tVal to 1.1 * (ship:mass*9.81)/ship:maxthrust.
Lock Steering to Heading(90,90) + R(0,Yaw,270).
Wait 1.
Until Alt:Radar < 120
{
        If Ship:surfacespeed > 12.5     {Set Yaw to -1.}
        If Ship:surfaceSpeed < 12.5     {Set Yaw to 5.}
        If Alt:Radar < 160
        {
                Set tVal to 1.5 * (ship:mass*9.81)/ship:maxthrust.
        } else If Ship:VerticalSpeed > 0
        {
                Set tVal to 0.
        } else If Ship:VerticalSpeed < 0
        {
                Set tVal to 1.3 * (ship:mass*9.81)/ship:maxthrust.
        }
}
Until Ship:SurfaceSpeed < 0.05
{
         If Ship:VerticalSpeed > 0
        {
                Set tVal to 0.
        } else If Ship:VerticalSpeed < 0
        {
                Set tVal to 1.3 * (ship:mass*9.81)/ship:maxthrust.
        }
        Set Yaw to -2 * Ship:SurfaceSpeed.
}
Set Yaw to 0.
Print "Descending".
Until Alt:Radar < 10
{
        Set targetSpeed to Alt:Radar/-10.
        If Ship:VerticalSpeed < targetSpeed
        {
                Set tVal to 1.1*(ship:mass*9.81)/ship:maxthrust.
        } else
        {
                Set tVal to 0.9*(ship:mass*9.81)/ship:maxthrust.
        }
       
}
Lock tVal to 0.95*(ship:mass*9.81)/ship:maxthrust.
Wait 2.
Print "Touchdown!".
