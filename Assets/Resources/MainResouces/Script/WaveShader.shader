Shader "Unlit/WaveShader"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Main Color",Color) = (1,1,1,1)//Color�v���p�e�B
	}
	SubShader
	{
		Tags { "RenderType" = "Transparent"
				"Queue" = "Transparent"
			 }
		Blend SrcAlpha OneMinusSrcAlpha
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};
	
			struct v2f
			{
				//�g�̓���
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};
	
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color; //�}�e���A������̃J���[
	
			//���_�V�F�[�_
			v2f vert(appdata v)
			{
				v2f o;
	
				//�g�̓���
				
				 o.vertex = v.vertex;
	
				 o.vertex.y += 15 * sin((v.vertex.x + _Time * 20) + (v.vertex.z + _Time * 20));
	
				 o.vertex = UnityObjectToClipPos(o.vertex);
				
	
				 return o;
			 }
	
			//�t���O�����g�V�F�[�_
			fixed4 frag(v2f i) : SV_Target
			{
				 fixed4 col = tex2D(_MainTex, i.uv) * _Color;
				UNITY_APPLY_FOG(i.fogCoord, col);

				//// �f�t�H���g�̃��t���N�V�����L���[�u�}�b�v���T���v�����O���āA���t���N�V�����x�N�g�����g�p���܂�
				//half4 skyData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, i.worldRefl);
				//// �L���[�u�}�b�v�f�[�^�����ۂ̃J���[�Ƀf�R�[�h���܂�
				//half3 skyColor = DecodeHDR(skyData, unity_SpecCube0_HDR);
				//// �o�͂��܂�
				//fixed4 c = 0;
				//c.rgb = skyColor;
				//return c;

				return col;
			}
			ENDCG
		}
	}
}
