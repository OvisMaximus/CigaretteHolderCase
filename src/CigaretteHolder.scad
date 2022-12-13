dHolder = 8.8;
lHolder = 160;
dMouthFront = 8.6;
dMouthConnector = 5.2;
lMouthConnector = 14;
wMouth = 9.4;
hMouth = 4.6;
lMouth = 110;
dRing = 9.3;
lRing = 6.5;
lTipAdapter = 35;
dTipAdapter = 10.9;

cadFix = 0.005;
$fn= 100;
module FrontPipe() {
    cylinder(lHolder, d=dHolder);
}

module MouthPipe() {
    cylinder(lMouth, d = wMouth);
    translate([0,0,lMouth - cadFix])
        cylinder(lMouthConnector + cadFix, d=hMouth);
    translate([0,0,lMouth])
        cylinder(lRing, d = wMouth);
}
module TipAdapter() {
    cylinder(lTipAdapter, d = dTipAdapter);
}