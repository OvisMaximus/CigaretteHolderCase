include <CigaretteHolder.scad>

renderMode = 1; // [0:render for print, 1: show cigarette holder]
SHOW_CIGARETTE_HOLDER = 1;

lWall = 1.2;
lSpacing = 0.3;
lPositionWall = 0.4;
lAngle = 10;
dAngleBore = 3 + 2 * lSpacing;
dAngleNut = 6.1;
lAngleNut = 4; // geschaetzt TODO
dAngleScrewHead = 5.5;
lAngleScrewHead = 4; // geschaetzt TODO

lHook = 20;
wHook = 2.2;

module endOfParameterSeparatorNop() {};

lPerimeter = 2 * (lWall + lSpacing);
lBox = lHolder + lPerimeter;
wBox = dTipAdapter + dHolder + 2 * lPerimeter;
hBox = dTipAdapter + lPerimeter;
hHook = hBox / 2;

dAngle = dAngleScrewHead + 0.2 + 2 * lWall;

module hook() {
    difference() {
        cube([lHook, wHook, hHook + cadFix]);
        translate([- cadFix, - cadFix, 0])
            cube([lHook + 2 * cadFix, wHook / 2 + cadFix, hHook / 2]);
        translate([- cadFix, - wHook * 2.5, hHook * 4 / 7])
            rotate([- 40, 0, 0])
                cube([lHook + 2 * cadFix, wHook * 2, hHook * 1.3]);
    }
}

module angleBase(xPos) {
    module angleBody() {
        cylinder(lAngle, d = dAngle);
        translate([- dAngle / 2, 0, 0])
            cube([dAngle / 2, dAngle / 2 + cadFix, lAngle]);

    }
    translate([xPos + lAngle / 2, 0, hBox / 2])
        rotate([0, - 90, 0])
            difference() {
                angleBody();
                translate([0, 0, - cadFix])
                    cylinder(lAngle + 2 * cadFix, d = dAngleBore);
                children();
            }
}

module angleNut(xPos = 0, isTop = true) {
    zPos = isTop? lAngle + cadFix - lAngleNut : - cadFix;
    angleBase(xPos)
    translate([0, 0, zPos])
        cylinder(lAngleNut + cadFix, d = dAngleNut + lSpacing, $fn = 6);
}

module angleScrewHeadHole(xPos = 0, isTop = true) {
    zPos = isTop? lAngle + cadFix - lAngleScrewHead : - cadFix;
    angleBase(xPos)
    translate([0, 0, zPos])
        cylinder(lAngleScrewHead + cadFix, d = dAngleNut + lSpacing);
}
module roundedEdgeMask(size = [1, 1, 1], edgeRadius = 1) {
    edgeDiameter = 2 * edgeRadius;
    boundingBoxSize = [size.x + 2, size.y + 2, size.z + 1 + cadFix];
    coreBoxSize = [size.x - edgeDiameter, size.y - edgeDiameter, size.z - edgeRadius + 2 * cadFix];
    cornerPositions = [
            [edgeRadius, edgeRadius, edgeRadius],
            [edgeRadius, size.y - edgeRadius, edgeRadius],
            [size.x - edgeRadius, edgeRadius, edgeRadius],
            [size.x - edgeRadius, size.y - edgeRadius, edgeRadius]];
    module freeSpaceWithoutChamfers() {
        translate([edgeRadius, edgeRadius, 0]) cube(coreBoxSize);
        for (xOfs = [0: edgeDiameter]) {
            translate([xOfs, edgeRadius, edgeRadius]) cube(coreBoxSize);
        }
        for (yOfs = [0: edgeDiameter]) {
            translate([edgeRadius, yOfs, edgeRadius]) cube(coreBoxSize);
        }
    }
    module verticalChamfers() {
        for (pos = cornerPositions)
        translate(pos)
            cylinder(size.z + 2 * cadFix, r = edgeRadius);
    }
    module horizontalChamfersX() {
        for (pos = [
                [edgeRadius, edgeRadius, edgeRadius],
                [edgeRadius, size.y - edgeRadius, edgeRadius]])
        translate(pos)
            rotate([0, 90, 0])
                cylinder(size.x - edgeDiameter, r = edgeRadius);
    }
    module horizontalChamfersY() {
        for (pos = [
                [edgeRadius, edgeRadius, edgeRadius],
                [size.x - edgeRadius, edgeRadius, edgeRadius]])
        translate(pos)
            rotate([- 90, 0, 0])
                cylinder(size.y - edgeDiameter, r = edgeRadius);
    }
    module roundCorners() {
        for(pos = cornerPositions)
        translate(pos)
            sphere(edgeRadius);
    }
    difference() {
        translate([- 1, - 1, - 1])cube(boundingBoxSize);
        freeSpaceWithoutChamfers();
        verticalChamfers();
        horizontalChamfersX();
        horizontalChamfersY();
        roundCorners();
    }
}

module halfCover(yPos) {
    yFrontPos = dHolder / 2 + lWall + lSpacing;
    yMouthPos = yFrontPos + lWall + 2 * lSpacing + dHolder;
    xAdapterPos = lBox - lPerimeter / 2 - lTipAdapter;
    yAdapterPos = yMouthPos + lPerimeter / 2;
    boxSize = [lBox, wBox, hBox / 2];
    translate([0, yPos, 0])
        difference() {
            cube(boxSize);
            for (x = [- 1:2:1],
                y = [- 1:2:1],
                z = [- 1:2:1]) {
                translate([lWall + lSpacing + x * lSpacing, yFrontPos + y * lSpacing, hBox / 2 + z * lSpacing])
                    rotate([0, 90, 0]) FrontPipe();
                translate([lWall + lSpacing + x * lSpacing, yMouthPos + y * lSpacing, hBox / 2 + z * lSpacing])
                    rotate([0, 90, 0]) MouthPipe();
                translate([xAdapterPos + x * lSpacing, yAdapterPos + y * lSpacing, hBox / 2 + z * lSpacing])
                    rotate([0, 90, 0]) TipAdapter();
            }
            roundedEdgeMask(boxSize, 2);
        }
}

coverPos = dAngle / 2;
halfCover(coverPos);

angleScrewHeadHole(25);
angleScrewHeadHole(lBox - 25, false);
translate([(lBox - lHook) / 2, dAngle / 2 + wBox - wHook, hBox / 2])
    hook();


difference() {
    mirror([0, 1, 0])
        translate([0, 1, 0])
            {
                halfCover(coverPos);
                angleNut(25 + lSpacing + lAngle, false);
                angleNut(lBox - 25 - lSpacing - lAngle);
            }
    translate([(lBox - lHook) / 2 - lSpacing, - dAngle / 2 - wBox - 1 - cadFix, - hBox * 1 / 4])
        cube([lHook + 2 * lSpacing, wHook / 2 + lSpacing, hBox]);
    translate([(lBox - lHook) / 2 - lSpacing, - dAngle / 2 - wBox - 1 - cadFix, - cadFix])
        cube([lHook + 2 * lSpacing, wHook + lSpacing, hBox / 4]);
}
if (renderMode == SHOW_CIGARETTE_HOLDER) {
    //Todo
    //color("purple", 0.3)
    //    translate([lPerimeter / 2, (wBox + dAngle) / 2, hBox / 2])
    //        syringe(0.5);
}
