function gadget:GetInfo()
	return {
		name = "we require more minerals",
		desc = "Renders minerals",
		author = "trepan, sprung",
		date = "15/7/07 - 15/1/13",
		license = "GNU GPL, v2 or later",
		layer = 0,
		enabled = true,
	}
end

local minerals_FDefID = FeatureDefNames["crystaltree1"] -- 
if (minerals_FDefID) then
	minerals_FDefID = minerals_FDefID.id
else
	return
end

local spGetFeatureDefID = Spring.GetFeatureDefID

if (gadgetHandler:IsSyncedCode()) then
	local spSetFeatureDirection = Spring.SetFeatureDirection
	local spSetFeatureAlwaysVisible = Spring.SetFeatureAlwaysVisible
	local spTransferFeature = Spring.TransferFeature
	local rand = math.random

	function gadget:FeatureCreated(fid)
		if (fid and spGetFeatureDefID(fid) == minerals_FDefID) then
			spSetFeatureAlwaysVisible(fid, true)
			spSetFeatureDirection(fid, 2*rand() - 1, 0, 2*rand() - 1)
		end
	end
else
	local GL_BACK                = GL.BACK
	local GL_LEQUAL              = GL.LEQUAL
	local GL_ONE                 = GL.ONE
	local GL_ONE_MINUS_SRC_ALPHA = GL.ONE_MINUS_SRC_ALPHA
	local GL_SRC_ALPHA           = GL.SRC_ALPHA
	local glBlending             = gl.Blending
	local glColor                = gl.Color
	local glCreateShader         = gl.CreateShader
	local glCulling              = gl.Culling
	local glDeleteShader         = gl.DeleteShader
	local glDepthTest            = gl.DepthTest
	local glFeature              = gl.Feature
	local glGetShaderLog         = gl.GetShaderLog
	local glLighting             = gl.Lighting
	local glPolygonOffset        = gl.PolygonOffset
	local glSmoothing            = gl.Smoothing
	local glUseShader            = gl.UseShader
	local spEcho                 = Spring.Echo
	local spGetAllFeatures       = Spring.GetAllFeatures
	local spGetVisibleUnits      = Spring.GetVisibleUnits
	local spGetUnitDefID         = Spring.GetUnitDefID

	local shader = nil

	function gadget:Shutdown()
		if (glCreateShader) then
			glDeleteShader(shader)
		end
	end

	function gadget:Initialize()

		if (glCreateShader) then
			shader = glCreateShader({

				uniform = {
					edgeExponent = 4,
				},

				vertex = [[
					// Application to vertex shader
					varying vec3 normal;
					varying vec3 eyeVec;
					varying vec3 color;
					uniform mat4 camera;
					uniform mat4 caminv;

					void main()
					{
						vec4 P = gl_ModelViewMatrix * gl_Vertex;
						eyeVec = P.xyz;
						normal  = gl_NormalMatrix * gl_Normal;
						color = gl_Color.rgb;
						gl_Position = gl_ProjectionMatrix * P;
					}
					]],  

				fragment = [[
					varying vec3 normal;
					varying vec3 eyeVec;
					varying vec3 color;

					uniform float edgeExponent;

					void main()
					{
						float opac = dot(normalize(normal), normalize(eyeVec));
						opac = 1.0 - abs(opac);
						opac = 0.55 + (0.55 * opac); 
						opac = pow(opac, edgeExponent);

						gl_FragColor.rgb = color;
						gl_FragColor.a = opac;
					}
				]],
			})
			if (shader == nil) then
				spEcho(glGetShaderLog())
				spEcho("Minerals failed")
			end
		end
	end

	function gadget:DrawWorld()
		glColor(0.5, 0.2, 1)
		if (shader) then
			glSmoothing(nil, nil, true)
			glUseShader(shader)
			glDepthTest(true)
			glBlending(GL_SRC_ALPHA, GL_ONE)
			glPolygonOffset(-2, -2)

			for _, fID in ipairs(spGetAllFeatures()) do
				if (spGetFeatureDefID(fID) == minerals_FDefID) then glFeature(fID, true) end
			end
			
			glUseShader(0)
			glBlending(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
			glSmoothing(nil, nil, false)
		else
			glDepthTest(GL_LEQUAL)
			glPolygonOffset(-10, -10)
			glColor(0,1,1,0.3)

			for _, fID in ipairs(spGetAllFeatures()) do
				if (spGetFeatureDefID(fID) == minerals_FDefID) then glFeature(fID, true) end
			end
		end
		glPolygonOffset(false)
		glDepthTest(false)
		glColor(1, 1, 1, 1)
	end
end