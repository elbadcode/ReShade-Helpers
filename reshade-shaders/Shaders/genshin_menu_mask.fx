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


uniform float BlackMaskPower <
	ui_category = "Amount";
	ui_label = "BlackMaskAmount";
	ui_type = "slider";
	ui_min = 0.0; ui_max = 2.0; ui_step = 0.1;
> = 1.0;
/*

uniform float ClampMax <
	ui_category = "Clamp";
	ui_label = "ClampMax";
	ui_type = "slider";
	ui_min = 0.0; ui_max = 1.0; ui_step = 1;
> = 1.0;
//+*/
uniform float Alpha <
	ui_category = "Clamp";
	ui_label = "Alpha";
	ui_type = "slider";
	ui_min = 0.0; ui_max = 1.0; ui_step = 0.1;
> = 0.1;
texture AlphaUIMask_Tex { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; };
sampler AlphaUIMask_Sampler { Texture = AlphaUIMask_Tex; };



void PS_AlphaUIMask(float4 pos : SV_Position, float2 texcoord : TEXCOORD, out float4 color0 : SV_Target0)

{
    float4 UIMask = tex2D(ReShade::BackBuffer, texcoord).a ;

    float4 MaskS = step(Alpha, UIMask) ;
	color0 = tex2D(ReShade::BackBuffer, texcoord) ;
	color0.a = MaskS.a ;
}

void PS_AlphaUIRestorePC(float4 pos : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target)
{	color = tex2D(ReShade::BackBuffer, texcoord);
}


void PS_AlphaUICut(float4 pos : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target)
{
	float4 GameScreen =  tex2D(AlphaUIMask_Sampler,texcoord);
	float4 CutS = step(Alpha, GameScreen) ;
    color.rgb = 0 ;
	color.a =  GameScreen.a * BlackMaskPower  ;

}
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
		outColor = lerp(beforeColor,afterColor, 1- clipped_depth);

   }
    
  void PS_Apply2(float4 vpos : SV_Position, float2 coords : TexCoord, out float4 outColor : SV_Target0) {
        float4 afterColor = getColor(coords);
        float4 beforeColor = getColorSampler(beforeSampler1,coords);
        float opacity = beforeColor.a > 0.34 ? beforeColor.a * 1.2 : beforeColor.a * 0.1;
		outColor = lerp(beforeColor,afterColor, 1- opacity);

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
     technique GENSHIN_UI_MASK_BOTTOM2<
        ui_label = "Genshin UI Mask Bottom2";
    > {
        pass {
        ClearRenderTargets = true;
            VertexShader = PostProcessVS;
            PixelShader = PS_Apply;
        }
    }
    
technique AlphaUIMask <
	ui_tooltip = "Keep UI";
>
{
	pass PS_AlphaUIMask
	{

		VertexShader = PostProcessVS;
		PixelShader = PS_AlphaUIMask;
		RenderTarget0 = AlphaUIMask_Tex;
	}

}
//////////////////////////////////////////////
technique AlphaUIRestore <
	ui_tooltip = "Restore UI";
>
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_AlphaUIRestorePC;

		ClearRenderTargets = false;
		
		BlendEnable = true;
		SrcBlend = SRCALPHA;
		DestBlend = INVSRCALPHA;
	}
	

}//////////////////////////////////
technique AlphaUICut <
	ui_tooltip = "black mask,prevent UI from affecting other fx";
>
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = PS_AlphaUICut;
		
		ClearRenderTargets = false;
		
		BlendEnable = true;
		SrcBlend = SRCALPHA;
		DestBlend = INVSRCALPHA;
		
		
// 		// Enable or disable the sten
		
	}
}
 


}