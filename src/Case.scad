cadFix = 0.005;

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

module hookRest(size, pos, lSpacing) {
    length = size.x + 2 * lSpacing;
    height = 2 * size.z;
    translate([pos.x - length / 2, pos.y, pos.z - height + cadFix]) {
        cube([length, size.y / 2 + lSpacing, height + lSpacing]);
        cube([length, size.y + lSpacing, 0.75 * height + lSpacing]);
    }
}

module cover(
    contentBoundingcontentBoundingBox = [100, 30, 10],
    sizeHook = [20, 2.2, 5],
    lSpacing = 0.2,
    lAngle = 10,
    dAngleBore = 3.4,
    dAngleNut = 6.1,
    lAngleNut = 4,
    dAngleScrewHead = 5.5,
    lAngleScrewHead = 4,
    lWall = 2.5,
    rEdge = 2,
    percentageBody = .5
) {
    function calcNumSegments(lEdge, lSegment) =
        let (n = floor(lEdge / lSegment))
            n > 4? 4 : n;

    function calcSize(oneSideAddOn, hookRestAddOn) =
        let (lAddOn = 2 * (oneSideAddOn))
            [contentBoundingcontentBoundingBox.x + lAddOn
            , contentBoundingcontentBoundingBox.y + lAddOn + hookRestAddOn
            , contentBoundingcontentBoundingBox.z + lAddOn];


    module validateArguments() {
        assert(lAngle >= lAngleScrewHead + lWall);
        assert(lAngle >= lAngleNut + lWall);
        assert(dAngleScrewHead <= dAngleBore + 2*lWall);
        assert(calcNumSegments(size.x - 2 * rEdge, lAngle) > 1);
        //assert(lWall > sqrt(rEdge * rEdge / 2));
        //assert(lWall > (sizeHook.y + lSpacing));
        //  hlid minimal rEdge + dAngle/2
    }

    module angleBase(pos, connectToSouth, hRampMax) {
        radius = dAngle/2;
        hRampOffset = (1 - 0.7071)*radius;
        hRampMaxInternal = hRampMax + hRampOffset;
        module ramp() {
            yMin45 = -radius * 1.7071;
            yMin = hRampMaxInternal + yMin45 < 0? - hRampMaxInternal : yMin45;
            rampPoints = connectToSouth
                ? [[0, 0], [0, radius * 1.7071], [yMin, 0]]
                : [[0, -(0.7071)*radius], [0, radius ], [yMin, radius]];
            linear_extrude(lAngle)
                polygon(rampPoints);
        }
        module angleBody() {
            cylinder(lAngle, d = dAngle);
            translate([ -radius, connectToSouth? -radius : 0, 0]) {
                cube([radius, radius + cadFix, lAngle]);
                translate([hRampOffset, 0, 0])
                    ramp();
            }

        }
        yPos = pos.y + (connectToSouth? dAngle : 0);
        translate([pos.x + lAngle / 2, yPos, pos.z])
            rotate([0, - 90, 0])
                difference() {
                    angleBody();
                    translate([0, 0, - cadFix])
                        cylinder(lAngle + 2 * cadFix, d = dAngleBore);
                    children();
                }
    }

    module angleNut(pos, atTop = true, connectToSouth = false, hRampMax = 0) {
        zPosNut = atTop? lAngle + cadFix - lAngleNut : - cadFix;
        angleBase(pos, connectToSouth, hRampMax)
            translate([0, 0, zPosNut])
                cylinder(lAngleNut + cadFix, d = dAngleNut, $fn = 6);
     }

    module angleScrewHead(pos, atTop = true, connectToSouth = false, hRampMax = 0) {
        zPosNut = atTop? lAngle + cadFix - lAngleScrewHead : - cadFix;
        angleBase(pos, connectToSouth, hRampMax)
            translate([0, 0, zPosNut])
                cylinder(lAngleScrewHead + cadFix, d = dAngleScrewHead);
    }

    module contentSpace() {
        minkowski() {
            children();
            cube([2*lSpacing,2*lSpacing,2*lSpacing]);
        }
    }

    module externalShape() {
        dEdge = 2 * rEdge;
        sizeNet = [size.x - dEdge, size.y -dEdge, size.z - dEdge];
        translate([rEdge,rEdge,rEdge])
            minkowski() {
                cube(sizeNet);
                sphere(r=rEdge);
            }
    }
    module closedcontentBoundingBox() {
        difference () {
            externalShape();
            translate([lWall, lWall, lWall])
                contentSpace() children();
        }
    }

    module lidAngles(hPos) {
        hRampMax = hPos - rEdge - dAngle / 2;
        angleScrewHead([rEdge + lAngleSpace + lAngle / 2 , -dAngle/2, hPos], true, false, hRampMax);
        if (angleSegments == 3 ) {
            angleNut([rEdge + lAngleSpace + 2 * (lAngle + lSpacing) + lAngle / 2, -dAngle/2, hPos], false, hRampMax);
        } else if (angleSegments > 3) {
            angleScrewHead([size.x - rEdge - lAngleSpace  - lAngle / 2, -dAngle/2, hPos], false, false, hRampMax);
        }
    }

    module lid() {
        percentageLid = 1 - percentageBody;
        hLid = size.z * percentageLid;

        translate([0, dAngle/2 + lSpacing, 0]) {
            difference() {
                closedcontentBoundingBox() children();
                translate([- cadFix, - cadFix, hLid])
                    scale(1.1) cube(size);
            }

            translate([(size.x - sizeHook.x) / 2, size.y - sizeHook.y, hLid - cadFix])
                    hook(sizeHook);

            lidAngles(hLid);
        }
    }

    module baseAngles(hPos) {
        hRampMax = hPos - rEdge - dAngle / 2;
        lDistanceFromSide = rEdge + lAngleSpace + lAngle * 3/2 + lSpacing;
        if (angleSegments != 3) {
            angleNut([lDistanceFromSide, - dAngle / 2, hPos], false, true, hRampMax);
        }
        if (angleSegments == 3 ) {
            angleBase([lDistanceFromSide, -dAngle/2, hPos], true, hRampMax);
        }
        if (angleSegments > 3) {
            angleNut([size.x - lDistanceFromSide, -dAngle/2, hPos], true, true, hRampMax);
        }
    }

    module base() {
        hBase = size.z * percentageBody;
        posHookRest = [size.x / 2, -size.y, hBase];

        translate([0, - dAngle/2 - lSpacing, 0]) {
            difference() {
                translate([0, 0, size.z])
                    rotate([180, 0, 0])
                        closedcontentBoundingBox() children();
                translate([- cadFix, cadFix - 1.1 * size.y, hBase])
                    scale(1.1) cube(size);
                hookRest(sizeHook, posHookRest, lSpacing);
            }

            baseAngles(hBase);
        }
    }

    size = calcSize(lWall + lSpacing, wHook - lWall);
    angleSegments = calcNumSegments(size.x - 2 * rEdge, lAngle);
    validateArguments();

    dAngle = max(dAngleScrewHead, dAngleNut) + 2 * (lSpacing + lWall);
    lAngleSpace = (size.x - angleSegments * (lSpacing + lAngle) - 2 * rEdge) /  (angleSegments > 3 ? 4 : 2);

    base() children();
    lid() children();

}
