/* dialV2_3.scad
 *
 * Copyright (C) Robert B. Ross, 2014
 *
 * Version 2.2 adjustments by Ludwig W. Wall, 2016
 *
 * Version 2.3 adjustments by Alexander E. Andrews, 2024
 *
 * This software is released under the Creative Commons
 * Attribution-ShareAlike 4.0 International Public License.
 *
 * Spiff Sans code from Stuart P. Bentley <stuart@testtrack4.com>
 *
 * TODO:
 *
 */

/* [Global] */

// 
// Maneuver Array can be directly copied from the dial field on a ship
// from https://github.com/xwingtmg/xwing-data2
// "<DISTANCE><MANEUVER><DIFFICULTY> 
// 

use <text_on_OpenSCAD/text_on.scad>
use <spiff-sans/SpiffSans.ttf>

ShipName = "TIE/FO FIGHTER";
Maneuver_Array = [
    "1TW",
    "1YW",
    "2LR",
    "2TB",
    "2BB",
    "2FB",
    "2NB",
    "2YB",
    "2PR",
    "3TW",
    "3BW",
    "3FB",
    "3NW",
    "3YW",
    "4FW",
    "4KR",
    "5FW"
  ];

part = "all"; // [all, bottom, top, pin]
view = "split"; // [combined, combined_view, split]

pinFit = -0.17; // pin won't actually fit if precisely same diameter as hole. Makes pin thinner.

/* [Hidden] */

$fn=120;
extRad = 22; // in mm
outerPostRad = 4;
innerPostRad = 2;
myScale=1.0;

/* MakerBot scheme for creating multiple STLs involves a "part" variable. */
if (view == "split") {
    /* individual print peice view */
    if (part == "bottom") { scale([myScale,myScale,1]) dialBottom(); }
    if (part == "top") { scale([myScale,myScale,1]) dialTop(); }
    if (part == "pin") { scale([myScale,myScale,1]) pin(pinFit); } 
    if (part == "all") {
        scale([myScale,myScale,1]) dialBottom();
        scale([myScale,myScale,1]) translate([42,0,0]) dialTop();
        scale([myScale,myScale,1]) translate([21,19,0]) pin(pinFit);
    }
}else if (view == "combined"){
    /* stack view */
	union() {
	    dialBottom();
	    rotate([0,0,360/16*8]) translate([0,0,5.4]) rotate([180,0,0]) dialTop();
	    translate([0,0,6.5]) rotate([180,0,0]) pin(pinFit);
	}
}
else if (view == "combined_view"){
    /* cut-away view */
    difference() {
	union() {
	    dialBottom();
	    rotate([0,0,360/16*8]) translate([0,0,5.4]) rotate([180,0,0]) dialTop();
	    translate([0,0,6.5]) rotate([180,0,0]) pin(pinFit);
	}
	translate([0,-40,-0.01]) cube([40,40,40], center=false);	
    }
}

/******** DIAL MODULES ********/

module dialBottom() {
    difference() {
	union() {
	    cylinder(r=extRad,h=3);
	    cylinder(r=outerPostRad, h=5.2);
        
	}
    
	translate([0,0,2]) cylinder(r=innerPostRad, h=7);
	translate([-0.2,0,3]) cube([0.4, outerPostRad+0.01, 7+0.01]);
    rotate([0,180,0]) translate([0,0,-.1]) shipname(false,1.8);    
    }

    translate([0,0,1]) maneuvers();
}

module dialTop() {
    difference() {
	union() {
	    cylinder(r=extRad,h=2.3);
	}
	union() {
	    translate([0,0,-0.01]) cylinder(r=outerPostRad, h=7);
	    translate([0,0,1.2]) cylinder(r=extRad - 2, h=1.21);
	    translate([0,7,-0.01]) linear_extrude(height=3.02)
		polygon(points = [[-2,0], [-4,11], [4,11], [2,0]],
			paths = [[0,1,2,3,0]]);
	}
    rotate([0,180,0]) translate([0,0,-1]) shipname(true,3);
    }
    
}

module pin(pinFit) {
    cylinder(r=outerPostRad+2, h=1);
    cylinder(r=innerPostRad + pinFit, h=4);
}

/******** SET SHIP NAME ********/
module shipname(direction,extrusion_height){
    r=outerPostRad+10;
    rotate([0,0,0])
    {
        translate([0,0,0])
        {
            //%circle(r=r);

            text_on_circle(t=ShipName,r=r,size=4,extrusion_height=extrusion_height,direction="ltr",font="arialblack:style=Bold",spacing=1.5,ccw=direction);

        }
    }
}


/******** MANEUVER MODULES ********/

module maneuvers() {
    for (i=[0:len(Maneuver_Array)-1]) {
        rotate([0,0,-1* 360/(len(Maneuver_Array))*i]){
            maneuver(Maneuver_Array[i]);
        }
    }
    
}

module maneuver(m) {
    color_text = (m[2] == "P") ? "purple" : "white";
    color(color_text) translate([-1.3,8.5,1.5]) scale([0.4,0.4,1]) linear_extrude(height=1.5)
	text(m[0], font = "Spiff Sans", size = 9);
    color_value = (m[2] == "R") ? "red" :
                  (m[2] == "B") ? "blue" :
                  (m[2] == "P") ? "purple" :
                  "white";
    
    color(color_value) translate([0,-1,0]) {
        if (m[1] == "B") {mirror([1,0,0]) rightBankIcon();}
        else if (m[1] == "N") {rightBankIcon();}
        else if (m[1] == "F") {straightIcon();}
        else if (m[1] == "Y") {rightTurnIcon();}
        else if (m[1] == "T") {mirror([1,0,0]) rightTurnIcon();}
        else if (m[1] == "R") {rightTalonIcon();}
        else if (m[1] == "E") {mirror([1,0,0]) rightTalonIcon();}
        else if (m[1] == "P") {rightSLoopIcon();}
        else if (m[1] == "L") {mirror([1,0,0]) rightSLoopIcon();}
        else if (m[1] == "D") {rightReverseBank();}
        else if (m[1] == "A") {mirror([1,0,0]) rightReverseBank();}
        else if (m[1] == "S") {reverseIcon();}
        else if (m[1] == "K") {kTurnIcon();}
        else {stopIcon();} // O is the key for stop
    } 
}

/******** ARROW MODULES ********/

module straightIcon() {
    straightPoints = [[-0.8,0], [-0.8,3], [-1.6,3], [0,4.6],
		      [1.6,3], [0.8,3], [0.8,0]];
    straightPath = [[0,1,2,3,4,5,6,0]];

    translate([0,14,0]) linear_extrude(height=3) {
	polygon(points=straightPoints, paths = straightPath);
    }
}

module reverseIcon() {
    
    reversePoints = [[-0.8,0], [-0.8,3], [-1.6,3], [0,4.6],
		      [1.6,3], [0.8,3], [0.8,0]];
    reversePath = [[0,1,2,3,4,5,6,0]];

    translate([0,14,0]) linear_extrude(height=3) {
        rotate(180,[0,0,1])
        translate([0,-4.7,0])
        polygon(points=reversePoints, paths = reversePath);
    }
}

module stopIcon() {
    stopPoints = [[-0.6,1], [-0.6,2.2], [0.6,2.2], [0.6,1]];
    stopPath   = [[0,1,2,3,0]];

    translate([0,14,0]) linear_extrude(height=3) {
	scale([1.5,1.5,0]) polygon(points=stopPoints, paths=stopPath);
    }
}

module rightTurnIcon() {
    rightTurnPoints = [[-2, 0], [-2,3.6], [0,3.6], [0,4.4],
		       [1.4,3], [0,1.6], [0,2.4], [-0.6,2.4], [-0.6,0]];
    rightTurnPath = [[0,1,2,3,4,5,6,7,8]];
 
     translate([0.4,14,0]) linear_extrude(height=3) {
	polygon(points=rightTurnPoints, paths=rightTurnPath);
    }
}
    
module rightBankIcon() {
    rightBankPoints = [[-1.6,0],[-1.58,2.2],[-1.57,2.4],[-1.56,2.5],[-1.55,2.6],[-1.52,2.7],[-1.48,2.8],[-1.42,2.9],[-1.35,3],[-1.24,3.1],[-1.10,3.2],[-0.9,3.3], [0.4-0.2,2+0.5],[0.4-0.34,2+0.4],[0.4-0.45,2+0.3],[0.4-0.52,2+0.2],[0.4-0.58,2+0.1],[0.4-0.62,2-0],[0.4-0.65,2-0.1],[0.4-0.66,2-0.2],[0.4-0.67,2-0.3],[0.4-0.68,2-0.4], [-0.28,0]];
    rightBankArrowPoints = [[-1.5,3.9], [0.7,3.9],[0.7,1.7]];

    translate([0.4,14,0]) linear_extrude(height=3) {
        polygon(points=rightBankPoints);
        polygon(points=rightBankArrowPoints);
    }
}

module rightTalonIcon() {
    
    rightTalonPoints = [[-0.8,0], [-0.8,4], [2.4,2.8], [2.4,2], [3.2,2],[2,1.0],
		   [0.8,2], [1.6,2], [1.6,2.8], [0.4,3.2], [0.4,0], [2.4,4], [2.4,3.2]];
    rightTalonPath = [[2,3,4,5,6,7,8],[10,0,1,11,12,9]];
 
    translate([-0.8,14,0]) linear_extrude(height=3) {
        polygon(points=rightTalonPoints, paths=rightTalonPath);
    }
}

module rightSLoopIcon() {
    
    rightSLoopPoints = [[-1.6,-0.8],[-1.58,2.2],[-1.57,2.4],[-1.56,2.5],[-1.55,2.6],[-1.52,2.7],[-1.48,2.8],[-1.42,2.9],[-1.35,3],[-1.24,3.1],[-1.10,3.2],[-0.35,3.55], [0.8-0.2,2.1+0.55],[0.4-0.34,2+0.4],[0.4-0.45,2+0.3],[0.4-0.52,2+0.2],[0.4-0.58,2+0.1],[0.4-0.62,2-0],[0.4-0.65,2-0.1],[0.4-0.66,2-0.2],[0.4-0.67,2-0.3],[0.4-0.68,2-0.4], [-0.28,-0.8]];
    rightSLoopArrowPoints = [[-1.4,3.1], [-1.4,1.7],[0,1.7]];

    
    translate([0.4,14,0]) linear_extrude(height=3) {
        translate([-0.2,0.8,0])
        polygon(points=rightSLoopPoints);
        translate([1.3,-0.4,0])
        polygon(points=rightSLoopArrowPoints);
        rotate(45,[0,0,1])
        translate([1.71,0.5,0])
        polygon(points=[[1,0],[1,1],[0,1],[0,0]]);
    }
}

module kTurnIcon() {
    kTurnPoints = [[-0.8,0], [-0.8,3.75], [-0.55,4], [2.4-0.25,4], [2.4,4-0.25], [2.4,2], [3.2,2],[2,1.0],
		   [0.8,2], [1.6,2], [1.6,3.2-0.25], [1.6-0.25,3.2], [0.4+0.25,3.2], [0.4,3.2-0.25], [0.4,0]];
    translate([-0.8,14,0]) linear_extrude(height=3) {
	polygon(points=kTurnPoints);
    }
}

module rightReverseBank() {
    rightBankPoints = [[-1.6,0],[-1.58,2.2],[-1.57,2.4],[-1.56,2.5],[-1.55,2.6],[-1.52,2.7],[-1.48,2.8],[-1.42,2.9],[-1.35,3],[-1.24,3.1],[-1.10,3.2],[-0.9,3.3], [0.4-0.2,2+0.5],[0.4-0.34,2+0.4],[0.4-0.45,2+0.3],[0.4-0.52,2+0.2],[0.4-0.58,2+0.1],[0.4-0.62,2-0],[0.4-0.65,2-0.1],[0.4-0.66,2-0.2],[0.4-0.67,2-0.3],[0.4-0.68,2-0.4], [-0.28,0]];
    rightBankArrowPoints = [[-1.5,3.9], [0.7,3.9],[0.7,1.7]];

    translate([0.6,14,0]) linear_extrude(height=3) {
        rotate(180,[0,0,1]) mirror([1,0,0]) translate([0,-4.7,0]) polygon(points=rightBankPoints);
        rotate(180,[0,0,1]) mirror([1,0,0]) translate([0,-4.7,0]) polygon(points=rightBankArrowPoints);
    }
}

/*
 * Local variables:
 *  mode: C
 *  c-indent-level: 4
 *  c-basic-offset: 4
 * End:
 *
 * vim: ts=8 sts=4 sw=4 expandtab
 */
