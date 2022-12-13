include <CigaretteHolder.scad>
include <Case.scad>

renderMode = 1; // [0:render for print, 1: show cigarette holder]
SHOW_CIGARETTE_HOLDER = 1;

lWall = 1.3;
lSpacing = 0.3;
lAngle = 12;
rEdge = 2;
dAngleBore = 3 + 2 * lSpacing;
dAngleNut = 6.1;
lAngleNut = 4; // geschaetzt TODO
dAngleScrewHead = 5.5;
lAngleScrewHead = 4; // geschaetzt TODO
lHook = 20;
wHook = 2.1;

module endOfParameterSeparatorNop() {};
if (renderMode != SHOW_CIGARETTE_HOLDER) {
    $fn = 120;
}

lPerimeter = 2 * (lWall + lSpacing);

contentBoundingBox = [
    lHolder + 2 * lSpacing,
    dHolder + lWall + dTipAdapter + 4 * lSpacing,
    dTipAdapter + 2 * lSpacing
];

xAdapter = contentBoundingBox.x - lTipAdapter - lSpacing;
yAdapter = lSpacing + dTipAdapter / 2;
xMouth = lSpacing;
yMouth = yAdapter;
xFront = lSpacing;
yFront = lSpacing + dTipAdapter + lSpacing + lWall + lSpacing + dHolder / 2;

zPos = contentBoundingBox.z / 2;

module content() {
    translate([xAdapter, yAdapter, zPos]) {
        rotate([0, 90,0])
            TipAdapter();
    }
    translate([xMouth, yMouth, zPos]) {
        rotate([0, 90,0])
            MouthPipe();
    }
    translate([xFront, yFront, zPos]) {
        rotate([0, 90,0])
            FrontPipe();
    }
}

cover (
    contentBoundingBox,
    [lHook, wHook, (contentBoundingBox.z - rEdge) / 2],
    lSpacing,
    lAngle,
    dAngleBore,
    dAngleNut,
    lAngleNut,
    dAngleScrewHead,
    lAngleScrewHead,
    lWall,
    rEdge
) {
    content();
}


if (renderMode == SHOW_CIGARETTE_HOLDER) {
    yOffset = 1;
    dAngle = (dAngleScrewHead > dAngleNut? dAngleScrewHead : dAngleNut) + 2 * (lSpacing + lWall);
    yCoverPos = dAngle / 2;
    translate([lWall, yOffset + yCoverPos, 0])
        color("purple", 0.3)
            content();
}
