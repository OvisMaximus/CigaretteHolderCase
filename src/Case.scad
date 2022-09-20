

module endOfParameterSeparatorNop() {};

cadFix = 0.005;
$fn = 50;

module hook(size) {
    difference() {
        cube([size.x, size.y, size.z + cadFix]);
        translate([- cadFix, - cadFix, 0])
            cube([size.x + 2 * cadFix, size.y / 2 + cadFix, size.z / 2]);
        translate([- cadFix, - size.y * 2.5, size.z * 4 / 7])
            rotate([- 40, 0, 0])
                cube([size.x + 2 * cadFix, size.y * 2, size.z * 1.3]);
    }
}

module angleBase(pos, length, diameter, dBore) {
    radius = diameter/2;
    module angleBody() {
        cylinder(length, d = diameter);
        translate([- radius, 0, 0])
            cube([radius, radius + cadFix, length]);

    }
    translate([pos.x + length / 2, pos.y, pos.z])
        rotate([0, - 90, 0])
            difference() {
                angleBody();
                translate([0, 0, - cadFix])
                    cylinder(length + 2 * cadFix, d = dBore);
                children();
            }
}

module angleNut(pos, length = 10, diameter = 6, dNut, lNut, dBore, atTop = true) {
    zPosNut = atTop? length + cadFix - lNut : - cadFix;
    angleBase(pos, length, diameter, dBore)
        translate([0, 0, zPosNut])
            cylinder(lNut + cadFix, d = dNut, $fn = 6);
}

module angleScrewHead(pos, length = 10, diameter = 6, dScrewHead, lScrewHead, dBore, atTop = true) {
    zPosNut = atTop? length + cadFix - lScrewHead : - cadFix;
    angleBase(pos, length, diameter, dBore)
        translate([0, 0, zPosNut])
            cylinder(lScrewHead + cadFix, d = dScrewHead);
}

module roundedEdgeMask(size, edgeRadius) {
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

module halfCover(pos, size, rEdge, spacing = 0.2) {
    boxSize = [size.x, size.y, size.z / 2];
    translate(pos)
        difference() {
            cube(boxSize);
            for (x = [- 1:2:1],
                y = [- 1:2:1],
                z = [- 1:2:1])
                translate([x * spacing, y * spacing, z * spacing])
                    children();
            roundedEdgeMask(boxSize, rEdge);
        }
}

module coverWithSpaceFor(
    lSpacing = 0.15,
    lAngle = 10,
    dAngleBore = 3.4,
    dAngleNut = 6.1,
    lAngleNut = 4,
    dAngleScrewHead = 5.5,
    lAngleScrewHead = 4,
    lWall = 1.4,
    rEdge = 2,
    size = [100, 30, 10],
    sizeHook = [20, 2.2, 5]
) {
    dAngle = dAngleScrewHead + 0.2 + 2 * lWall;
    zPosAngle = size.z/4 + dAngle/2;

    coverPos = [0, dAngle / 2, 0];
    halfCover(coverPos, size, rEdge, lSpacing)
        children();


    angleScrewHead([25, 0, zPosAngle], lAngle, dAngle, dAngleScrewHead, lAngleScrewHead, dAngleBore, true);
    angleScrewHead([size.x - 25, 0, zPosAngle], lAngle, dAngle, dAngleScrewHead, lAngleScrewHead, dAngleBore, false);
    translate([(size.x - sizeHook.x) / 2, dAngle / 2 + size.y - sizeHook.y, size.z / 2])
        hook(sizeHook);

    yOffset = 1;
    difference() {
        mirror([0, 1, 0])
            translate([0, yOffset, 0])
                {
                    halfCover(coverPos, size, rEdge, lSpacing)
                        children();
                    angleNut([25 + lSpacing + lAngle, 0, zPosAngle], lAngle, dAngle, dAngleNut, lAngleNut, dAngleBore, false);
                    angleNut([size.x - 25 - lSpacing - lAngle, 0, zPosAngle], lAngle, dAngle, dAngleNut, lAngleNut, dAngleBore, true);
                }
        translate([(size.x - lHook) / 2 - lSpacing, - dAngle / 2 - size.y - yOffset - cadFix, - size.z * 1 / 4])
            cube([lHook + 2 * lSpacing, wHook / 2 + lSpacing, size.z]);
        translate([(size.x - lHook) / 2 - lSpacing, - dAngle / 2 - size.y - yOffset - cadFix, - cadFix])
            cube([lHook + 2 * lSpacing, wHook + lSpacing, size.z / 4]);
    }
}


