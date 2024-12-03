////////////////////////////////////////////////////////////////////////////////////////////////
//
// DH_UBER_MASK 0.3.1
//
// This shader is free, if you paid for it, you have been ripped and should ask for a refund.
//
// This shader is developed by AlucardDH (Damien Hembert)
//
// Get more here : https://github.com/AlucardDH/dh-reshade-shaders
//
////////////////////////////////////////////////////////////////////////////////////////////////
#include "Reshade.fxh"


// MACROS /////////////////////////////////////////////////////////////////
// Don't touch this
#define getColor(c) tex2Dlod(ReShade::BackBuffer,float4(c,0,0))
#define getColorSamplerLod(s,c,l) tex2Dlod(s,float4(c.xy,0,l))
#define getColorSampler(s,c) tex2Dlod(s,float4(c.xy,0,0))
#define maxOf3(a) max(max(a.x,a.y),a.z)
#define minOf3(a) min(min(a.x,a.y),a.z)
#define avgOf3(a) ((a.x+a.y+a.z)/3.0)
//////////////////////////////////////////////////////////////////////////////

namespace DH_UBER_MASK {

// Textures
    texture beforeTex { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
    sampler beforeSampler { Texture = beforeTex; };
    texture beforeTex3 { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
    sampler beforeSampler3 { Texture = beforeTex3; };
    texture beforeTex2 { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
    sampler beforeSampler2 { Texture = beforeTex2; };
        texture beforeTex4 { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; };
    sampler beforeSampler4 { Texture = beforeTex4; };


// Parameters    
    /*
    uniform float fTest <
        ui_type = "slider";
        ui_min = 0.0; ui_max = 10.0;
        ui_step = 0.001;
    > = 0.001;
    uniform bool bTest = true;
    uniform bool bTest2 = true;
    uniform bool bTest3 = true;
    */
    


// Mask 1 depth and brightness
    uniform int iDebug1 <
        ui_category = "mask 1";
        ui_type = "combo";
        ui_label = "Display";
        ui_items = "Output\0Full Mask\0Mask overlay\0";
        ui_tooltip = "Debug the intermediate steps of the shader";
    > = 0;
    uniform float3 fDepthMaskNear <
        ui_text = "Center/Range/Strength:";
        ui_type = "slider";
        ui_category = "mask 1";
        ui_label = "Near";
        ui_min = 0.0; ui_max = 1.0;
        ui_step = 0.001;
        ui_tooltip = "";
    > = float3(0.0,0.5,0.0);
    
    uniform float3 fDepthMaskMid <
        ui_type = "slider";
        ui_category = "mask 1";
        ui_label = "Mid";
        ui_min = 0.0; ui_max = 1.0;
        ui_step = 0.001;
        ui_tooltip = "";
    > = float3(0.5,0.5,0.0);

    uniform float3 fDepthMaskFar <
        ui_type = "slider";
        ui_category = "mask 1";
        ui_label = "Far";
        ui_min = 0.0; ui_max = 1.0;
        ui_step = 0.001;
        ui_tooltip = "";
    > = float3(1.0,0.5,0.5);
    
    
    uniform float3 fBrightnessMaskDark <
        ui_text = "Center/Range/Strength:";
        ui_type = "slider";
        ui_category = "mask 1";
        ui_label = "Dark";
        ui_min = 0.0; ui_max = 1.0;
        ui_step = 0.001;
        ui_tooltip = "";
    > = float3(0.0,0.5,0.1);

    uniform float3 fBrightnessMaskMid <
        ui_type = "slider";
        ui_category = "mask 1";
        ui_label = "Mid";
        ui_min = 0.0; ui_max = 1.0;
        ui_step = 0.001;
        ui_tooltip = "";
    > = float3(0.5,0.25,0.25);

    uniform float3 fBrightnessMaskBright <
        ui_type = "slider";
        ui_category = "mask 1";
        ui_label = "Bright";
        ui_min = 0.0; ui_max = 1.0;
        ui_step = 0.001;
        ui_tooltip = "";
    > = float3(1.0,0.5,0.75);
    
    uniform int iBrightnessMethod <
        ui_type = "combo";
        ui_category = "mask 1";
        ui_label = "Method";
        ui_items = "Max\0Avg\0Min\0";
        ui_min = 0; ui_max = 2;
        ui_step = 1;
        ui_tooltip = "";
    > = 0;
    
    uniform float2 fDiffMask <
        ui_text = "Range/Strength:";
        ui_type = "slider";
        ui_category = "mask 1";
        ui_label = "Difference";
        ui_min = 0.0; ui_max = 2.0;
        ui_step = 0.001;
        ui_tooltip = "";
    > = float2(1.0,1.0);
    
    uniform int iDiffMethod <
        ui_type = "combo";
        ui_category = "mask 1";
        ui_label = "Method";
        ui_items = "Max\0Avg\0Min\0";
        ui_min = 0; ui_max = 2;
        ui_step = 1;
        ui_tooltip = "";
    > = 0; 

    
   //mask 2 depth/alpha only 
    
        uniform int iDebug2 <
        ui_category = "mask 2";
        ui_type = "combo";
        ui_label = "Display";
        ui_items = "Output\0Full Mask\0Mask overlay\0";
        ui_tooltip = "Debug the intermediate steps of the shader";
    > = 0;
    
    uniform float3 fDepthMaskNear2 <
        ui_text = "Center/Range/Strength:";
        ui_type = "slider";
        ui_category = "mask 2";
        ui_label = "Near";
        ui_min = 0.0; ui_max = 1.0;
        ui_step = 0.001;
        ui_tooltip = "";
    > = float3(0.0,0.5,0.0);
    
    uniform float3 fDepthMaskMid2 <
        ui_type = "slider";
        ui_category = "mask 2";
        ui_label = "Mid";
        ui_min = 0.0; ui_max = 1.0;
        ui_step = 0.001;
        ui_tooltip = "";
    > = float3(0.5,0.5,0.0);

    uniform float3 fDepthMaskFar2 <
        ui_type = "slider";
        ui_category = "mask 2";
        ui_label = "Far";
        ui_min = 0.0; ui_max = 1.0;
        ui_step = 0.001;
        ui_tooltip = "";
    > = float3(1.0,0.5,0.5);
    
      uniform float fAlphaScalar2 <
        ui_text = "Range/Strength:";
        ui_type = "slider";
        ui_category = "mask 2";
        ui_label = "Alpha adjustment";
        ui_min = 0.0; ui_max = 2.0;
        ui_step = 0.001;
        ui_tooltip = "";
    > = float(1.0);
    
    
    //mask 3 depth/alpha only 
       uniform int iDebug3 <
        ui_category = "mask 3";
        ui_type = "combo";
        ui_label = "Display";
        ui_items = "Output\0Full Mask\0Mask overlay\0";
        ui_tooltip = "Debug the intermediate steps of the shader";
    > = 0;
    
    uniform float3 fDepthMaskNear3 <
        ui_text = "Center/Range/Strength:";
        ui_type = "slider";
        ui_category = "mask 3";
        ui_label = "Near";
        ui_min = 0.0; ui_max = 1.0;
        ui_step = 0.001;
        ui_tooltip = "";
    > = float3(0.0,0.5,0.0);
    
    uniform float3 fDepthMaskMid3 <
        ui_type = "slider";
        ui_category = "mask 3";
        ui_label = "Mid";
        ui_min = 0.0; ui_max = 1.0;
        ui_step = 0.001;
        ui_tooltip = "";
    > = float3(0.5,0.5,0.0);

    uniform float3 fDepthMaskFar3 <
        ui_type = "slider";
        ui_category = "mask 3";
        ui_label = "Far";
        ui_min = 0.0; ui_max = 1.0;
        ui_step = 0.001;
        ui_tooltip = "";
    > = float3(1.0,0.5,0.5);
    
      uniform float fAlphaScalar3 <
        ui_text = "Range/Strength:";
        ui_type = "slider";
        ui_category = "mask 3";
        ui_label = "Alpha adjustment";
        ui_min = 0.0; ui_max = 2.0;
        ui_step = 0.001;
        ui_tooltip = "";
    > = float(1.0);
    
    
    
   //mask 4 depth, brightness, alpha
       
        uniform int iDebug4 <
        ui_category = "mask 4";
        ui_type = "combo";
        ui_label = "Display";
        ui_items = "Output\0Full Mask\0Mask overlay\0";
        ui_tooltip = "Debug the intermediate steps of the shader";
    > = 0;
       
        uniform float3 fDepthMaskNear4 <
        ui_text = "Center/Range/Strength:";
        ui_type = "slider";
        ui_category = "mask 4";
        ui_label = "Near";
        ui_min = 0.0; ui_max = 1.0;
        ui_step = 0.001;
        ui_tooltip = "";
    > = float3(0.0,0.5,0.0);
    
    uniform float3 fDepthMaskMid4 <
        ui_type = "slider";
        ui_category = "mask 4";
        ui_label = "Mid";
        ui_min = 0.0; ui_max = 1.0;
        ui_step = 0.001;
        ui_tooltip = "";
    > = float3(0.5,0.5,0.0);

    uniform float3 fDepthMaskFar4 <
        ui_type = "slider";
        ui_category = "mask 4";
        ui_label = "Far";
        ui_min = 0.0; ui_max = 1.0;
        ui_step = 0.001;
        ui_tooltip = "";
    > = float3(1.0,0.5,0.5);
    
        uniform float3 fBrightnessMaskDark4 <
        ui_text = "Center/Range/Strength:";
        ui_type = "slider";
        ui_category = "mask 4";
        ui_label = "Dark";
        ui_min = 0.0; ui_max = 1.0;
        ui_step = 0.001;
        ui_tooltip = "";
    > = float3(0.0,0.5,0.1);

    uniform float3 fBrightnessMaskMid4 <
        ui_type = "slider";
        ui_category = "mask 4";
        ui_label = "Mid";
        ui_min = 0.0; ui_max = 1.0;
        ui_step = 0.001;
        ui_tooltip = "";
    > = float3(0.5,0.25,0.25);

    uniform float3 fBrightnessMaskBright4 <
        ui_type = "slider";
        ui_category = "mask 4";
        ui_label = "Bright";
        ui_min = 0.0; ui_max = 1.0;
        ui_step = 0.001;
        ui_tooltip = "";
    > = float3(1.0,0.5,0.75);
    
    uniform int iBrightnessMethod4 <
        ui_type = "combo";
        ui_category = "mask 4";
        ui_label = "Method";
        ui_items = "Max\0Avg\0Min\0";
        ui_min = 0; ui_max = 2;
        ui_step = 1;
        ui_tooltip = "";
    > = 0;

  uniform float fAlphaScalar4 <
        ui_text = "Range/Strength:";
        ui_type = "slider";
        ui_category = "mask 4";
        ui_label = "Alpha adjustment";
        ui_min = 0.0; ui_max = 2.0;
        ui_step = 0.001;
        ui_tooltip = "";
    > = float(1.0);
    
    uniform float2 fDiffMask4 <
        ui_text = "Range/Strength:";
        ui_type = "slider";
        ui_category = "mask 4";
        ui_label = "Difference";
        ui_min = 0.0; ui_max = 2.0;
        ui_step = 0.001;
        ui_tooltip = "";
    > = float2(1.0,1.0);
    
    uniform int iDiffMethod4 <
        ui_type = "combo";
        ui_category = "mask 4";
        ui_label = "Method";
        ui_items = "Max\0Avg\0Min\0";
        ui_min = 0; ui_max = 2;
        ui_step = 1;
        ui_tooltip = "";
    > = 0; 


   uniform float fDepthMaskAnimatedPos<
        ui_type = "slider";
        ui_category = "animated mask";
        ui_label = "Depth bounds";
        ui_min = 0.0; ui_max = 1.0;
        ui_step = 0.001;
        ui_tooltip = "";
    > = 0.1;
    
      uniform float fDepthMaskAnimatedWidth<
        ui_type = "slider";
        ui_category = "animated mask";
        ui_label = "Depth width";
        ui_min = 0.0; ui_max = 1.0;
        ui_step = 0.001;
        ui_tooltip = "";
    > = 0.2;
    
          uniform float fDepthMaskAnimatedSpeed<
        ui_type = "slider";
        ui_category = "animated mask";
        ui_label = "speed";
        ui_min = 0.0; ui_max = 10.0;
        ui_step = 0.001;
        ui_tooltip = "";
    > = 0.2;
    uniform bool Flip <
	ui_category = "animated mask";
	ui_label = "FLip";
	ui_type = "checkbox";
> = false;
    uniform float2 pingpong <
	source = "pingpong"; 
	min = 0.0; max = 1.0; 
	step = 0.2; 
	smoothing = 0.01; 
	>;
	
	    uniform bool MouseControl <
	ui_category = "animated mask";
	ui_label = "Mouse wheel control";
	ui_type = "checkbox";
> = false;
	
        uniform float2 mouse_value < source = "mousewheel"; min = 0.0; max = 10.0; > = 1.0;
        
float when_gt(float x, float y) {
    return max(sign(x - y), 0.0f);
}

float when_le(float x, float y) {
    return 1.0f - when_gt(x, y);
}

float when_lt(float x, float y) {
    return max(sign(y - x), 0.0f);
}

// PS

    void PS_Save(float4 vpos : SV_Position, float2 coords : TexCoord, out float4 outColor : SV_Target0) {
        outColor = getColor(coords);
    }
    
    float computeMask(float value, float3 params) {
    	if(value<=params[0]) {
    		return smoothstep(params[0]-params[1],params[0],value)*params[2];
    	} else {
    		return (1.0-smoothstep(params[0],params[0]+params[1],value))*params[2];
    	}
    }
    
    float getBrightness(float3 color) {
    	if(iBrightnessMethod==0) {
    		return maxOf3(color);
    	}
    	if(iBrightnessMethod==1) {
    		return avgOf3(color);
    	}
    	return minOf3(color);
    }
    
    float getDifference(float3 before,float3 after) {
    	float3 diff = abs(before-after);
    	if(iDiffMethod==0) {
    		return maxOf3(diff);
    	}
    	if(iDiffMethod==1) {
    		return avgOf3(diff);
    	}
    	return minOf3(diff);
    }

    void PS_Apply(float4 vpos : SV_Position, float2 coords : TexCoord, out float4 outColor : SV_Target0) {
        float4 afterColor = getColor(coords);
        float4 beforeColor = getColorSampler(beforeSampler,coords);

        float mask = 0.0;
        
        float depth = ReShade::GetLinearizedDepth(coords);
        mask += computeMask(depth,fDepthMaskNear);
        mask += computeMask(depth,fDepthMaskMid);
        mask += computeMask(depth,fDepthMaskFar);

        float brightness = getBrightness(beforeColor.rgb);
        mask += computeMask(brightness,fBrightnessMaskDark);
        mask += computeMask(brightness,fBrightnessMaskMid);
        mask += computeMask(brightness,fBrightnessMaskBright);
        
        float diff = saturate(getDifference(beforeColor.rgb,afterColor.rgb)*2.0);
        mask += computeMask(diff,float3(1.0,fDiffMask));

		mask = saturate(mask);
		if(iDebug1==1) {
        	outColor = float4(mask,mask,mask,1.0);
		} else if(iDebug1==2) {
        	outColor = lerp(afterColor,float4(0,1,0,1),mask);
		} else {
        	outColor = lerp(beforeColor,afterColor,1.0-mask);
        }
    }


void PS_Apply3(float4 vpos : SV_Position, float2 coords : TexCoord, out float4 outColor : SV_Target0) {
        float4 afterColor = getColor(coords);
        float4 beforeColor3 = getColorSampler(beforeSampler3,coords);

        float mask = 0.0;
        
        float depth = ReShade::GetLinearizedDepth(coords);
        mask += computeMask(depth,fDepthMaskNear3);
        mask += computeMask(depth,fDepthMaskMid3);
        mask += computeMask(depth,fDepthMaskFar3);

        float brightness = getBrightness(beforeColor3.rgb);

        
     //   float diff = saturate(getDifference(beforeColor3.rgb,afterColor.rgb)*2.0);
     //   mask += computeMask(diff,float3(1.0,fDiffMask));

		mask = saturate(mask);
		if(iDebug3==1) {
        	outColor = float4(mask,mask,mask, fAlphaScalar3);
		} else if(iDebug3==2) {
        	outColor = lerp(afterColor,float4(0,1,0,1),mask);
		} else {
        	outColor = lerp(beforeColor3,afterColor, fAlphaScalar3 - mask);
        }
    }


void PS_Apply2(float4 vpos : SV_Position, float2 coords : TexCoord, out float4 outColor : SV_Target0) {
        float4 afterColor = getColor(coords);
        float4 beforeColor2 = getColorSampler(beforeSampler2,coords);
			
        float mask = 0.0;
        
        float depth = ReShade::GetLinearizedDepth(coords);
        mask += computeMask(depth,fDepthMaskNear2);
        mask += computeMask(depth,fDepthMaskMid2 );
        mask += computeMask(depth,fDepthMaskFar2);

        float brightness = getBrightness(beforeColor2.rgb);
        
     //   float diff = saturate(getDifference(beforeColor2.rgb,afterColor.rgb)*2.0);
     //   mask += computeMask(diff,float3(1.0,fDiffMask));

		mask = saturate(mask);
		if(iDebug2==1) {
        	outColor = float4(mask,mask,mask, fAlphaScalar2);
		} else if(iDebug2==2) {
        	outColor = lerp(afterColor,float4(0,1,0,1),mask);
		} else {
        	outColor = lerp(beforeColor2,afterColor, fAlphaScalar2-mask);
        }
    }
    
    void PS_Apply4(float4 vpos : SV_Position, float2 coords : TexCoord, out float4 outColor : SV_Target0) {
        float4 afterColor = getColor(coords);
        float4 beforeColor4 = getColorSampler(beforeSampler4,coords);

        float mask = 0.0;
        
        float depth = ReShade::GetLinearizedDepth(coords);
        mask += computeMask(depth,fDepthMaskNear4);
        mask += computeMask(depth,fDepthMaskMid4);
        mask += computeMask(depth,fDepthMaskFar4);

        float brightness = beforeColor4.a * fAlphaScalar4;
        mask += computeMask(brightness,fBrightnessMaskDark4);
        mask += computeMask(brightness,fBrightnessMaskMid4);
        mask += computeMask(brightness,fBrightnessMaskBright4);
        
        //float diff = afterColor.a - brightness 
       
		 float diff = saturate(getDifference(1.0,afterColor.a)*4.0);
        mask += computeMask(diff,float3(1.0,fDiffMask4));
		
		mask = saturate(mask);
		if(iDebug4==1) {
        	outColor = float4(mask,mask,mask, fAlphaScalar4);
		} else if(iDebug4==2) {
        	outColor = lerp(afterColor,float4(0,1,0,1),mask);
		} else {
        	float4 oColor = lerp(beforeColor4,afterColor,fAlphaScalar4  - mask); 
        	oColor.a = fAlphaScalar4;
        	outColor = oColor;
        }
    }
    
    void PS_ApplyBeforeAlpha(float4 vpos : SV_Position, float2 coords : TexCoord, out float4 outColor : SV_Target0) {
    	float4 beforeColor = getColorSampler(beforeSampler, coords);
    	beforeColor.a *= 0.5f * when_lt(beforeColor.a, 1.0F);
    	if(coords.x > 500 && coords.x < 1500) outColor.a = 0f;
    	
    	outColor = beforeColor;
    }

	void PS_ApplyAnimated(float4 vpos : SV_Position, float2 coords : TexCoord, out float4 outColor : SV_Target0) {
        float4 afterColor = getColor(coords);
        float4 beforeColor = getColorSampler(beforeSampler,coords);
				float speed = MouseControl ? mouse_value.x * 0.1 :  pingpong.x ;

	

	const float depthOffset =  speed * fDepthMaskAnimatedSpeed;
        float mask = 0.0;
        
        float depth = ReShade::GetLinearizedDepth(coords);
        mask += computeMask(depth,float3(fDepthMaskAnimatedPos - depthOffset, fDepthMaskAnimatedWidth, 1.0));
      

 
     //   float diff = saturate(getDifference(beforeColor2.rgb,afterColor.rgb)*2.0);
     //   mask += computeMask(diff,float3(1.0,fDiffMask));

		mask =  Flip ? 1- saturate(mask):  saturate(mask);
		if(iDebug2==1) {
        	outColor =  float4(mask,mask,mask,1.0);
		} else if(iDebug2==2) {
        	outColor = lerp(afterColor,float4(0,1,0,1),mask);
		} else {
        	outColor = lerp(beforeColor,afterColor, 1.0-mask);
        }
    }
    



// TEHCNIQUES 
    
    
     technique DH_UBER_MASK_BEFORE_2<
        ui_label = "DH_UBER_MASK 0.3.1 BEFORE 2";
    > {
        pass {
            VertexShader = PostProcessVS;
            PixelShader = PS_Save;
            RenderTarget = beforeTex2;
        }
    }

    technique DH_UBER_MASK_AFTER_2<
        ui_label = "DH_UBER_MASK 0.3.1 AFTER 2";
    > {
        pass {
            VertexShader = PostProcessVS;
            PixelShader = PS_Apply2;
        }
    }
    
        technique DH_UBER_MASK_BEFORE_3<
        ui_label = "DH_UBER_MASK 0.3.1 BEFORE 3";
    > {
        pass {
            VertexShader = PostProcessVS;
            PixelShader = PS_Save;
            RenderTarget = beforeTex3;
        }
    }

    technique DH_UBER_MASK_AFTER_3<
        ui_label = "DH_UBER_MASK 0.3.1 AFTER 3";
    > {
        pass {
            VertexShader = PostProcessVS;
            PixelShader = PS_Apply3;
        }
    }
    
    
     
        technique DH_UBER_MASK_BEFORE_4<
        ui_label = "DH_UBER_MASK 0.3.1 BEFORE Alpha";
    > {
        pass {
            VertexShader = PostProcessVS;
            PixelShader = PS_Save;
            RenderTarget = beforeTex4;
        }
    }

    technique DH_UBER_MASK_AFTER_4<
        ui_label = "DH_UBER_MASK 0.3.1 AFTER Alpha";
    > {
        pass {
            VertexShader = PostProcessVS;
            PixelShader = PS_Apply4;
                     BlendOp = Max;
 		BlendOpAlpha = Max;
 	 BlendEnable = true;
        }
    }
    
        technique DH_UBER_MASK_ANIMATED_BEFORE<
        ui_label = "DH_UBER_MASK 0.3.1 ANIMATED BEFORE";
    > {
        pass {
            VertexShader = PostProcessVS;
            PixelShader = PS_Save;
            RenderTarget = beforeTex;
            
        }
    }

    technique  DH_UBER_MASK_ANIMATED_AFTER<
        ui_label = "DH_UBER_MASK 0.3.1 ANIMATED AFTER";
    > {
        pass {
            VertexShader = PostProcessVS;
            PixelShader = PS_ApplyAnimated;
                     BlendOp = Max;
 		BlendOpAlpha = Max;
 	 BlendEnable = true;
        }
    }
    technique DH_UBER_MASK_BEFORE<
        ui_label = "DH_UBER_MASK 0.3.1 BEFORE";
    > {
        pass {
            VertexShader = PostProcessVS;
            PixelShader = PS_Save;
            RenderTarget = beforeTex;
            
        }
    }

    technique DH_UBER_MASK_AFTER<
        ui_label = "DH_UBER_MASK 0.3.1 AFTER";
    > {
        pass {
            VertexShader = PostProcessVS;
            PixelShader = PS_Apply;
                     BlendOp = Max;
 		BlendOpAlpha = Max;
 	 BlendEnable = true;
        }
    }
    
    technique DH_INPUT_AS_OUTPUT<
        ui_label = "DH_INPUT_AS_OUTPUT";
    > {
        pass {
            VertexShader = PostProcessVS;
            PixelShader = PS_ApplyBeforeAlpha;
                     BlendOp = Add;
 		BlendOpAlpha =Add;
 				SrcBlend = SRCCOLOR;
		DestBlend = INVSRCCOLOR;
 	 BlendEnable = true;
        }
    }

}
