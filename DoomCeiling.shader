shader "CYF/DoomCeiling"
{
	Properties
    {
        _MainTex("Sprite Texture", 2D) = "white" {}
    }
	SubShader
	{
		Tags {"Queue" = "Transparent"}

        Cull Back
        Lighting Off
        Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
		CGPROGRAM
			#pragma require geometry
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			
			float4x4 mod, MVP;

			v2f vert(appdata v)
			{
				v2f o;
				
				o.uv = v.uv;
				o.vertex = v.vertex;
				
				return o;
			}
			
			/*
			Documentation on geometry shaders is scarce, so
			Credits to przemyslawzaworski, whose work i used as a reference
			https://github.com/przemyslawzaworski/Unity3D-CG-programming/blob/master/GeometryShaders/Cube.shader
			*/

			//What follows is a complete and utter mess, but a very perfomant mess.
			
			float4 vert1,vert2,vert3,vert4,vert5,vert6,vert7,vert8,vert9,vert10,vert11,vert12,vert13,vert14,vert15,vert16,vert17,vert18,vert19;
			float4 vert20,vert21,vert22,vert23,vert24,vert25,vert26,vert27,vert28,vert29,vert30,vert31,vert32,vert33,vert34,vert35,vert36,vert37,vert38,vert39;
			float4 vert40,vert41,vert42,vert43,vert44,vert45,vert46,vert47,vert48,vert49,vert50,vert51,vert52,vert53,vert54,vert55,vert56,vert57,vert58,vert59;
			float4 vert60,vert61,vert62,vert63,vert64,vert65,vert66,vert67,vert68,vert69,vert70,vert71,vert72,vert73,vert74,vert75,vert76,vert77,vert78,vert79;
			float4 vert80,vert81,vert82,vert83,vert84,vert85,vert86,vert87,vert88,vert89,vert90,vert91,vert92,vert93,vert94,vert95,vert96,vert97,vert98,vert99;
			
			[maxvertexcount(99)]
			void geom(triangle v2f patch[3], inout TriangleStream<v2f> tristream, uint pid : SV_PRIMITIVEID)
			{
				v2f o;
				if (pid == 0)
				{
					MVP[0].y = 0;
					o.vertex = mul(MVP, vert1);
					o.uv = vert1.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert2);
					o.uv = vert2.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert3);
					o.uv = vert3.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert4);
					o.uv = vert4.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert5);
					o.uv = vert5.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert6);
					o.uv = vert6.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert7);
					o.uv = vert7.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert8);
					o.uv = vert8.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert9);
					o.uv = vert9.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert10);
					o.uv = vert10.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert11);
					o.uv = vert11.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert12);
					o.uv = vert12.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert13);
					o.uv = vert13.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert14);
					o.uv = vert14.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert15);
					o.uv = vert15.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert16);
					o.uv = vert16.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert17);
					o.uv = vert17.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert18);
					o.uv = vert18.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert19);
					o.uv = vert19.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert20);
					o.uv = vert20.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert21);
					o.uv = vert21.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert22);
					o.uv = vert22.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert23);
					o.uv = vert23.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert24);
					o.uv = vert24.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert25);
					o.uv = vert25.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert26);
					o.uv = vert26.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert27);
					o.uv = vert27.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert28);
					o.uv = vert28.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert29);
					o.uv = vert29.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert30);
					o.uv = vert30.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert31);
					o.uv = vert31.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert32);
					o.uv = vert32.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert33);
					o.uv = vert33.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert34);
					o.uv = vert34.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert35);
					o.uv = vert35.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert36);
					o.uv = vert36.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert37);
					o.uv = vert37.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert38);
					o.uv = vert38.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert39);
					o.uv = vert39.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert40);
					o.uv = vert40.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert41);
					o.uv = vert41.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert42);
					o.uv = vert42.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert43);
					o.uv = vert43.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert44);
					o.uv = vert44.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert45);
					o.uv = vert45.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert46);
					o.uv = vert46.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert47);
					o.uv = vert47.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert48);
					o.uv = vert48.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert49);
					o.uv = vert49.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert50);
					o.uv = vert50.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert51);
					o.uv = vert51.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert52);
					o.uv = vert52.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert53);
					o.uv = vert53.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert54);
					o.uv = vert54.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert55);
					o.uv = vert55.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert56);
					o.uv = vert56.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert57);
					o.uv = vert57.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert58);
					o.uv = vert58.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert59);
					o.uv = vert59.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert60);
					o.uv = vert60.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert61);
					o.uv = vert61.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert62);
					o.uv = vert62.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert63);
					o.uv = vert63.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert64);
					o.uv = vert64.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert65);
					o.uv = vert65.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert66);
					o.uv = vert66.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert67);
					o.uv = vert67.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert68);
					o.uv = vert68.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert69);
					o.uv = vert69.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert70);
					o.uv = vert70.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert71);
					o.uv = vert71.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert72);
					o.uv = vert72.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert73);
					o.uv = vert73.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert74);
					o.uv = vert74.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert75);
					o.uv = vert75.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert76);
					o.uv = vert76.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert77);
					o.uv = vert77.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert78);
					o.uv = vert78.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert79);
					o.uv = vert79.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert80);
					o.uv = vert80.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert81);
					o.uv = vert81.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert82);
					o.uv = vert82.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert83);
					o.uv = vert83.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert84);
					o.uv = vert84.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert85);
					o.uv = vert85.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert86);
					o.uv = vert86.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert87);
					o.uv = vert87.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert88);
					o.uv = vert88.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert89);
					o.uv = vert89.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert90);
					o.uv = vert90.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert91);
					o.uv = vert91.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert92);
					o.uv = vert92.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert93);
					o.uv = vert93.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert94);
					o.uv = vert94.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert95);
					o.uv = vert95.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert96);
					o.uv = vert96.xz;
					tristream.Append(o);
					tristream.RestartStrip();
					o.vertex = mul(MVP, vert97);
					o.uv = vert97.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert98);
					o.uv = vert98.xz;
					tristream.Append(o);
					o.vertex = mul(MVP, vert99);
					o.uv = vert99.xz;
					tristream.Append(o);
					tristream.RestartStrip();
				}
			}

			fixed4 frag(v2f i) : SV_Target
            {
				return tex2D(_MainTex, i.uv);
            }
		ENDCG
		}
	}
}
