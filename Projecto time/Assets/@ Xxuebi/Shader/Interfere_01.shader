// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "@Xxuebi/Interfere_01"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_MainTex_Color("MainTex_Color", Color) = (1,1,1,1)
		_NoiseTex("NoiseTex", 2D) = "white" {}
		_U_NoiseSpeed("U_NoiseSpeed", Float) = 1
		_V_NoiseSpeed("V_NoiseSpeed", Float) = 0
		_NoiseMask("NoiseMask", 2D) = "white" {}
		_U_NoiseMaskS("U_NoiseMaskS", Float) = 1
		_V_NoiseMaskS("V_NoiseMaskS", Float) = 0
		_Noise_Int("Noise_Int", Range( 0 , 0.5)) = 0
		_RB_Offset("RB_Offset", Vector) = (0.03,0,-0.03,0)
		[Toggle(_AUTO_SPEED_ON)] _Auto_Speed("Auto_Speed", Float) = 0
		_Speed_Int("Speed_Int", Float) = 2

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#pragma shader_feature_local _AUTO_SPEED_ON


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float4 _MainTex_Color;
			uniform sampler2D _MainTex;
			uniform sampler2D _NoiseTex;
			uniform float _U_NoiseSpeed;
			uniform float _V_NoiseSpeed;
			uniform float4 _NoiseTex_ST;
			uniform sampler2D _NoiseMask;
			uniform float _U_NoiseMaskS;
			uniform float _V_NoiseMaskS;
			uniform float4 _NoiseMask_ST;
			uniform float _Noise_Int;
			uniform float _Speed_Int;
			uniform float4 _RB_Offset;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float2 texCoord13 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult12 = (float2(_U_NoiseSpeed , _V_NoiseSpeed));
				float2 uv_NoiseTex = i.ase_texcoord1.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
				float2 panner8 = ( 1.0 * _Time.y * appendResult12 + uv_NoiseTex);
				float2 appendResult38 = (float2(_U_NoiseMaskS , _V_NoiseMaskS));
				float2 uv_NoiseMask = i.ase_texcoord1.xy * _NoiseMask_ST.xy + _NoiseMask_ST.zw;
				float2 panner40 = ( 1.0 * _Time.y * appendResult38 + uv_NoiseMask);
				float mulTime31 = _Time.y * _Speed_Int;
				#ifdef _AUTO_SPEED_ON
				float staticSwitch37 = ( _Noise_Int * sin( mulTime31 ) );
				#else
				float staticSwitch37 = _Noise_Int;
				#endif
				float temp_output_33_0 = saturate( staticSwitch37 );
				float2 appendResult15 = (float2(( texCoord13.x + ( (0.0 + (( tex2D( _NoiseTex, panner8 ).r * tex2D( _NoiseMask, panner40 ).r ) - 0.0) * (0.5 - 0.0) / (1.0 - 0.0)) * temp_output_33_0 ) ) , texCoord13.y));
				float4 break23 = ( (0.0 + (temp_output_33_0 - 0.0) * (1.0 - 0.0) / (0.5 - 0.0)) * _RB_Offset );
				float2 appendResult24 = (float2(break23.x , break23.y));
				float4 tex2DNode4 = tex2D( _MainTex, appendResult15 );
				float2 appendResult25 = (float2(break23.z , break23.w));
				float4 appendResult28 = (float4(tex2D( _MainTex, ( appendResult15 + appendResult24 ) ).r , tex2DNode4.g , tex2D( _MainTex, ( appendResult15 + appendResult25 ) ).b , tex2DNode4.a));
				
				
				finalColor = ( _MainTex_Color * appendResult28 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
500;259;1926;1120;186.3102;1057.328;1.339202;True;True
Node;AmplifyShaderEditor.RangedFloatNode;34;-2924.076,274.4824;Inherit;False;Property;_Speed_Int;Speed_Int;11;0;Create;True;0;0;0;False;0;False;2;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;31;-2684.667,272.0396;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-3078.212,-557.8876;Inherit;False;Property;_U_NoiseSpeed;U_NoiseSpeed;3;0;Create;True;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-3077.914,-459.7877;Inherit;False;Property;_V_NoiseSpeed;V_NoiseSpeed;4;0;Create;True;0;0;0;False;0;False;0;-0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-3088.249,-58.4733;Inherit;False;Property;_V_NoiseMaskS;V_NoiseMaskS;7;0;Create;True;0;0;0;False;0;False;0;-1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-3088.547,-156.5732;Inherit;False;Property;_U_NoiseMaskS;U_NoiseMaskS;6;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;12;-2880.614,-514.9875;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SinOpNode;30;-2475.794,272.0397;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-2640.86,48.8111;Inherit;False;Property;_Noise_Int;Noise_Int;8;0;Create;True;0;0;0;False;0;False;0;0.259;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;38;-2890.949,-113.6731;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-3093.811,-751.5874;Inherit;False;0;7;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;39;-3104.146,-350.273;Inherit;False;0;41;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-2185.973,127.3697;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;8;-2758.41,-724.2872;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;40;-2768.745,-322.9728;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;37;-1999.662,0.7109394;Inherit;False;Property;_Auto_Speed;Auto_Speed;10;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;7;-2541.908,-737.4872;Inherit;True;Property;_NoiseTex;NoiseTex;2;0;Create;True;0;0;0;False;0;False;-1;None;612f7739d1c6aa747bf3f11fabcfe2fc;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;41;-2552.243,-336.1728;Inherit;True;Property;_NoiseMask;NoiseMask;5;0;Create;True;0;0;0;False;0;False;-1;None;1bda3197e6979e1439ae68e9e7ec95b9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;33;-1705.119,61.94534;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-2211.282,-473.4537;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;22;-1187.41,319.8339;Inherit;False;Property;_RB_Offset;RB_Offset;9;0;Create;True;0;0;0;False;0;False;0.03,0,-0.03,0;0.03,0,0.03,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;29;-1934.829,-386.2662;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;18;-1197.01,33.43421;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;13;-1618.03,-776.0712;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-1280.21,-289.7658;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-867.41,169.4341;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-1191.388,-839.7224;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;23;-702.1098,174.9341;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;25;-492.4211,313.4566;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;24;-499.4211,166.4566;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;15;-845.5845,-631.9152;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;27;-190.0217,178.4726;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;2;-574.5552,-881.895;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;0;False;0;False;None;58ecd3f8690b31f44b41d2c894576d02;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleAddOpNode;26;-248.9052,-255.2116;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;3;192.4068,-373.6267;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;193.263,-125.4754;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;192.2084,115.8655;Inherit;True;Property;_TextureSample2;Texture Sample 2;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;36;884.0001,-550.5767;Inherit;False;Property;_MainTex_Color;MainTex_Color;1;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;28;860.9191,-154.3834;Inherit;True;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;1386.851,-233.6607;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;1768.607,-156.0077;Float;False;True;-1;2;ASEMaterialInspector;100;1;@Xxuebi/Interfere_01;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;2;5;False;-1;10;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;2;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
WireConnection;31;0;34;0
WireConnection;12;0;9;0
WireConnection;12;1;10;0
WireConnection;30;0;31;0
WireConnection;38;0;42;0
WireConnection;38;1;43;0
WireConnection;32;0;17;0
WireConnection;32;1;30;0
WireConnection;8;0;6;0
WireConnection;8;2;12;0
WireConnection;40;0;39;0
WireConnection;40;2;38;0
WireConnection;37;1;17;0
WireConnection;37;0;32;0
WireConnection;7;1;8;0
WireConnection;41;1;40;0
WireConnection;33;0;37;0
WireConnection;44;0;7;1
WireConnection;44;1;41;1
WireConnection;29;0;44;0
WireConnection;18;0;33;0
WireConnection;16;0;29;0
WireConnection;16;1;33;0
WireConnection;19;0;18;0
WireConnection;19;1;22;0
WireConnection;14;0;13;1
WireConnection;14;1;16;0
WireConnection;23;0;19;0
WireConnection;25;0;23;2
WireConnection;25;1;23;3
WireConnection;24;0;23;0
WireConnection;24;1;23;1
WireConnection;15;0;14;0
WireConnection;15;1;13;2
WireConnection;27;0;15;0
WireConnection;27;1;25;0
WireConnection;26;0;15;0
WireConnection;26;1;24;0
WireConnection;3;0;2;0
WireConnection;3;1;26;0
WireConnection;4;0;2;0
WireConnection;4;1;15;0
WireConnection;5;0;2;0
WireConnection;5;1;27;0
WireConnection;28;0;3;1
WireConnection;28;1;4;2
WireConnection;28;2;5;3
WireConnection;28;3;4;4
WireConnection;35;0;36;0
WireConnection;35;1;28;0
WireConnection;1;0;35;0
ASEEND*/
//CHKSM=0F4787AECF7B5F3EC6724B2C0872AF8B8F9F87CB