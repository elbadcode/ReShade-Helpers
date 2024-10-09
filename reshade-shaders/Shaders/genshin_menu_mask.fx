////////////////////////////////////////////////////////////////////////////////////////////////
//
// GENSHIN UI MASK BY LOBOTOMYX
// The game always uses 1.0 depth for menus and the map so this is very easy. probably useless on other games
//

#include "Reshade.fxh"


#define getColor(c) tex2Dlod(ReShade::BackBuffer,float4(c,0,0))
#define getColorSamplerLod(s,c,l) tex2Dlod(s,float4(c.xy,0,l))
#define getColorSampler(s,c) tex2Dlod(s,float4(c.xy,0,0))



namespace GENSHIN_UI_MASK {

// Textures


uniform float Smooth <
	ui_category = "Smooth";
	ui_label = "Smooth";
	ui_type = "slider";
	ui_min = 0.9; ui_max = 1.0; ui_step = 0.01;
> = 0.99;
//+*/




    texture beforeTex { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; };
    sampler beforeSampler { Texture = beforeTex; };
     texture beforeTex1 { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; };
    sampler beforeSampler1 { Texture = beforeTex1; };
	texture2D texDepthBuffer : DEPTH;
 uniform bool has_depth < source = "bufready_depth"; >;

    void PS_Save(float4 vpos : SV_Position, float2 coords : TexCoord, out float4 outColor : SV_Target0,  out float4 outColor1 : SV_Target1) {
        outColor = getColor(coords);
        outColor1 = getColor(coords);
    }
   
    void PS_Apply(float4 vpos : SV_Position, float2 coords : TexCoord, out float4 outColor : SV_Target0) {
        float4 afterColor = getColor(coords);
        float4 beforeColor = getColorSampler(beforeSampler,coords);
 	   float depth = ReShade::GetLinearizedDepth(coords);  
		float clipped_depth = any(depth < saturate(depth)) ? 0  : depth;
		outColor = lerp(beforeColor,afterColor,( 1- clipped_depth)*Smooth);

   }
   
    


// TEHCNIQUES 
    
    technique GENSHIN_UI_MASK_TOP<
        ui_label = "Genshin UI Mask TOP";
    > {
        pass {
            VertexShader = PostProcessVS;
            PixelShader = PS_Save;
            RenderTarget0 = beforeTex;
            RenderTarget1 = beforeTex1;
        }
    }

    technique GENSHIN_UI_MASK_BOTTOM<
        ui_label = "Genshin UI Mask Bottom";
    > {
        pass {
        ClearRenderTargets = true;
            VertexShader = PostProcessVS;
            PixelShader = PS_Apply;
        }
    }
  
    
