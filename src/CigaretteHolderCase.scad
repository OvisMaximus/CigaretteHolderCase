include <CigaretteHolder.scad>
include <Case.scad>

renderMode = 1; // [0:render for print, 1: show cigarette holder]
SHOW_CIGARETTE_HOLDER = 1;

lWall = 1.2;
lSpacing = 0.3;
lAngle = 10;
rEdge = 2;
dAngleBore = 3 + 2 * lSpacing;
dAngleNut = 6.1;
lAngleNut = 4; // geschaetzt TODO
dAngleScrewHead = 5.5;
lAngleScrewHead = 4; // geschaetzt TODO
lHook = 20;
wHook = 2.2;

module endOfParameterSeparatorNop() {};

lPerimeter = 2 * (lWall + lSpacing);

box = [
    lHolder + lPerimeter,
    2 * lPerimeter + dHolder + dMouthFront + 2*lSpacing,
    dTipAdapter + lPerimeter
];

yFrontPos = dHolder / 2 + lWall + lSpacing;
yMouthPos = yFrontPos + lWall + 2 * lSpacing + dHolder;
xAdapterPos = box.x - lPerimeter / 2 - lTipAdapter;
yAdapterPos = yMouthPos + 2 * lSpacing;

coverWithSpaceFor(
    lSpacing,
    lAngle,
    dAngleBore,
    dAngleNut,
    lAngleNut,
    dAngleScrewHead,
    lAngleScrewHead,
    lWall,
    rEdge,
    box,
    [lHook, wHook, box.z / 2]
) {
    translate([lWall + lSpacing, yFrontPos + lSpacing, box.z / 2 + lSpacing])
        rotate([0, 90, 0]) FrontPipe();
    translate([lWall + lSpacing, yMouthPos + lSpacing, box.z / 2 + lSpacing])
        rotate([0, 90, 0]) MouthPipe();
    translate([xAdapterPos + lSpacing, yAdapterPos + lSpacing, box.z / 2 + lSpacing])
        rotate([0, 90, 0]) TipAdapter();
}


if (renderMode == SHOW_CIGARETTE_HOLDER) {
    yOffset = 1;
    dAngle = dAngleScrewHead > dAngleNut? dAngleScrewHead : dAngleNut + lSpacing + lWall;
    yCoverPos = dAngle / 2;
    color("purple", 0.3) {
        translate([lPerimeter / 2 + lSpacing, -yMouthPos - yCoverPos - yOffset - lSpacing, box.z / 2 + lSpacing])
            rotate([0,90,0])
                MouthPipe();
        translate([lPerimeter / 2 + lSpacing, -yFrontPos - yCoverPos - yOffset - lSpacing, box.z / 2 + lSpacing])
            rotate([0,90,0])
                FrontPipe();
        translate([xAdapterPos + lSpacing, -yAdapterPos - yCoverPos - yOffset - lSpacing, box.z / 2 + lSpacing])
            rotate([0,90,0])
                TipAdapter();
    }
}
