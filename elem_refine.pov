//povray elem_refine.pov +H1000 +W1000 +A +R9
#include "colors.inc"

#declare CR = 0.011; 

#macro mytexture(mycolor)
	texture{ pigment{ color mycolor}
          //finish { phong 1 ambient 0.10 diffuse 0.9}
       } // end of texture
#end

#macro mytexture1(mycolor)
	texture{ pigment{ color mycolor}
          finish { phong 1.0 brilliance 4 metallic phong_size = 40}
       } // end of texture
#end

#macro quad(p0,p1)
	cylinder{<p0.x, p0.y, p0.z>, <p1.x, p0.y, p0.z>, CR mytexture(Blue)}
	cylinder{<p1.x, p0.y, p0.z>, <p1.x, p1.y, p0.z>, CR mytexture(Blue)}
	cylinder{<p1.x, p1.y, p0.z>, <p0.x, p1.y, p0.z>, CR mytexture(Blue)}
	cylinder{<p0.x, p1.y, p0.z>, <p0.x, p0.y, p0.z>, CR mytexture(Blue)}
#end

#macro Hex(p0,p1)
	//bottom
	quad(<p0.x,p0.y,p0.z>, <p1.x,p1.y,p0.z>)
	//top
	quad(<p0.x,p0.y,p1.z>, <p1.x,p1.y,p1.z>)
	//vertical lines
	cylinder{<p0.x, p0.y, p0.z>, <p0.x, p0.y, p1.z>, CR mytexture(Blue)}
	cylinder{<p1.x, p0.y, p0.z>, <p1.x, p0.y, p1.z>, CR mytexture(Blue)}
	cylinder{<p1.x, p1.y, p0.z>, <p1.x, p1.y, p1.z>, CR mytexture(Blue)}
	cylinder{<p0.x, p1.y, p0.z>, <p0.x, p1.y, p1.z>, CR mytexture(Blue)}
#end

#macro refined_Hex(p0,p1)
    // bottom blocks
    Hex(<p0.x,            p0.y, p0.z>,             <(p0.x+p1.x)/2, (p0.y+p1.y)/2, (p0.z+p1.z)/2>)
    Hex(<(p0.x+p1.x)/2, p0.y, p0.z>,             <p1.x,             (p0.y+p1.y)/2, (p0.z+p1.z)/2>)
    Hex(<p0.x,            p0.y, (p0.z+p1.z)/2>,     <(p0.x+p1.x)/2, (p0.y+p1.y)/2, p1.z>)
    Hex(<(p0.x+p1.x)/2, p0.y, (p0.z+p1.z)/2>,     <p1.x,             (p0.y+p1.y)/2, p1.z>)
    //top blocks
    Hex(<p0.x,             (p0.y+p1.y)/2, p0.z>,             <(p0.x+p1.x)/2, p1.y, (p0.z+p1.z)/2>)
    Hex(<(p0.x+p1.x)/2, (p0.y+p1.y)/2, p0.z>,             <p1.x,             p1.y, (p0.z+p1.z)/2>)
    Hex(<p0.x,             (p0.y+p1.y)/2, (p0.z+p1.z)/2>,     <(p0.x+p1.x)/2, p1.y, p1.z>)
    Hex(<(p0.x+p1.x)/2, (p0.y+p1.y)/2, (p0.z+p1.z)/2>,     <p1.x,             p1.y, p1.z>)
#end

#macro myaxis(p0,p1,p2,Cl)
    cylinder{<p0.x,p0.y,p0.z> , <p1.x,p1.y,p1.z>, CylRadius pigment {color Cl} }
    cone{<p1.x,p1.y,p1.z>,3*CylRadius, <p2.x,p2.y,p2.z>, 0 pigment {color Cl} }
#end
 


#declare camloc = <3.5 2, -4>;

light_source {camloc color White*0.25}
light_source {<-50, 150, -75> color White}

camera{
	perspective
	location camloc
	look_at <1,0,1>
}

background{color White}

Hex(<0,0,0>,<1,1,1>)
refined_Hex(<1,0,0>,<2,1,1>)
refined_Hex(<0,1,0>,<1,2,1>)
Hex(<0,-1,0>,<1,0,1>)
Hex(<1,-1,0>,<2,0,1>)
Hex(<0,-2,0>,<2,-1,2>)



#declare BT =
 texture{ pigment{ color Red}
          finish { phong 1.0 }
        } // end of texture

sphere {<0.5, 1.5, 0.5>,0.05 mytexture(Red)}

sphere {<0.5, 1.0, 0.5>,0.05 mytexture(Red)}

sphere {<1.0, 1.0, 0.5>,0.05 mytexture(Red)}
//sphere {<0.0, 1.0, 0.5>,0.05 mytexture(SpringGreen)}
sphere {<1.0, 1.0, 0.0>,0.05 mytexture(Red)}
//sphere {<0.5, 1.0, 1.0>,0.05 mytexture(SpringGreen)}

//sphere {<1.0, 0.0, 0.5>,0.05 mytexture(Red)}

//sphere {<1.0, 0.0, 0.0>,0.05 mytexture(Red)}
//sphere {<1.0, 0.0, 1.0>,0.05 mytexture(Red)}

sphere {<1.0, -1.0, 0.0>,0.05 mytexture(Red)}
sphere {<0.0, -1.0, 0.0>,0.05 mytexture(rgb<1,0,0>)}
sphere {<2.0, -1.0, 0.0>,0.05 mytexture(Red)}

text {
    ttf "timrom.ttf" "A" 0.1, 0
    pigment { Red }
    scale<0.2,0.2,0.2>
    translate <0.55, 1.55,0.4>
  }

text {
    ttf "timrom.ttf" "B" 0.1, 0
    pigment { Red }
    scale<0.2,0.2,0.2>
    translate <0.58, 1.05,0.4>
  }

text {
    ttf "timrom.ttf" "C" 0.1, 0
    pigment { Red }
    scale<0.2,0.2,0.2>
    translate <1.05, 1.05,0.5>
  }

text {
    ttf "timrom.ttf" "D" 0.1, 0
    pigment { Red }
    scale<0.2,0.2,0.2>
    translate <0.83, 0.80,-0.0>
  }

//text {
//   ttf "timrom.ttf" "E" 0.1, 0
//    pigment { Red }
//    scale<0.2,0.2,0.2>
//    translate <1.15, -0.08,-0.2>
//  }

text {
    ttf "timrom.ttf" "E" 0.1, 0
    pigment { Red }
    scale<0.2,0.2,0.2>
    translate <1.0, -1.2, 0.0>
  }

text {
    ttf "timrom.ttf" "F" 0.1, 0
    pigment { Red }
    scale<0.2,0.2,0.2>
    translate <0.0, -1.2, 0.0>
  }

text {
    ttf "timrom.ttf" "G" 0.1, 0
    pigment { Red }
    scale<0.2,0.2,0.2>
    translate <2.0, -1.2, 0.0>
  }





