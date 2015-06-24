// feetIR Подглядел на Reddit. Данный скрипт контролирует, чтобы ноги робота всегда были параллельны поверхности ;)
// Оригинал - http://www.reddit.com/r/Kos/comments/3apstr/thanks_to_ozins_help_a_kos_program_to_level_robot/

// ------------------------function of ozin to get normalvector-------------------------
// parameter 1: a geoposition ( ship:GEOPOSITION / body:GEOPOSITIONOF(position) / LATLNG(latitude,longitude) )
// parameter 2: size/"radius" of the triangle. Small number gives a local normalvector while a larger one will tend to give a more average normalvector.
// returns: Normalvector of the terrain. (Can be used to determine the slope of the terrain.)
function geo_normalvector {
        parameter geopos,size_.
        set size to max(5,size_).
        local center is geopos.
        local fwd is vxcl(center-body:position,body:angularvel):normalized.
        local right is vcrs(fwd,center-body:position):normalized.
        local p1 is body:geopositionof(center + fwd * size_ + right * size_).
        local p2 is body:geopositionof(center + fwd * size_ - right * size_).
        local p3 is body:geopositionof(center - fwd * size_).

        local vec1 is p1:position-p3:position.
        local vec2 is p2:position-p3:position.
        local normalVec is vcrs(vec1,vec2):normalized.

        //debug vecdraw: local markNormal is vecs_add(center,normalVec * 300,rgb(1,0,1),"slope: " + round(vang(center-body:position,normalVec),1) ).

        return normalVec.
}

//----------------------------------------------------------------------------------------

//foot: must nametag the feet parts and the ankle IR parts
set leftfoot to ship:partstagged("leftfoot").
set leftfoot to leftfoot[0]. 

set rightfoot to ship:partstagged("rightfoot").
set rightfoot to rightfoot[0].



//ankles

set leftankle to ship:partstagged("leftankle").
set leftankle to leftankle[0].
set leftankleMod to leftankle:getmodule("MuMechToggle").
leftankleMod:setfield("Acceleration",50).

set rightankle to ship:partstagged("rightankle").
set rightankle to rightankle[0].
set rightankleMod to rightankle:getmodule("MuMechToggle").
rightankleMod:setfield("Acceleration",50).


//starts the loop
ag9 off.
until ag9 {


//antinormal vector from terrain under the part

set leftnegNormalVec to geo_normalvector(leftfoot:POSITION,5) * -1.
set rightnegNormalVec to geo_normalvector(rightfoot:POSITION,5) * -1.


// get the angle between foot:facing:vector and the "pitch-component" of the normalvec

set leftpitchError to vang(leftfoot:facing:vector, vxcl(leftfoot:facing:starvector,leftnegNormalVec)).
set rightpitchError to vang(rightfoot:facing:vector, vxcl(rightfoot:facing:starvector,rightnegNormalVec)).

// determine if that angle should be negative
if vdot(leftfoot:facing:topvector, leftnegNormalVec) < 0 set leftpitchError to -leftpitchError.
if vdot(rightfoot:facing:topvector, rightnegNormalVec) < 0 set rightpitchError to -rightpitchError.


//DEFINES THE MOVEMENT SPEED DEPENDING ON THE ERROR.
LEFTANKLEMOD:SETFIELD("speed",abs(leftpitcherror/2)).
RIGHTANKLEMOD:SETFIELD("speed",abs(rightpitcherror/2)).

// MOVES THE ANKLE ACCORDING TO THE ANGLE BETWEEN THE VECTORS
if leftpitchError < -0.5 leftankleMod:doaction("move +",true).
else if leftpitcherror > 0.5 leftankleMod:doaction("move -",true).
else { leftankleMod:doaction("move +",false). leftankleMod:doaction("move -",false). }

if rightpitchError < -0.5  rightankleMod:doaction("move +",true).
else if rightpitchError > 0.5 rightankleMod:doaction("move -",true).
else { rightankleMod:doaction("move +",false). rightankleMod:doaction("move -",false). }

//TEST: DRAWING ONLY A VECTOR TO SEE HOW IT GOES.
set drawFacingVector1 to VECDRAWARGS(leftfoot:position, leftfoot:facing:vector, red, "leftfoot facing vector", 1, TRUE ).
set drawFacingVector2 to VECDRAWARGS(rightfoot:position, rightfoot:facing:vector, green, "rightfoot facing vector", 1, TRUE ).


//close the loop
wait 0.01.
}

//remove the vector
set drawFacingVector1:show to false.
set drawFacingVector2:show to false.
