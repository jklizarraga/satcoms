  module AstosTelecom __precompile__()

  export TransceiverSimple, transceiversimple2xml, SatelliteBody, satellitebody2xml, earth2xml, modeldata2xml, AssemblyElement, assemblyelement2xml, Assembly, assembly2xml, Satellite, modeldefinition2xml, Sensor

  using LightXML

  abstract GenericComponent

  abstract Sensor <: GenericComponent

  abstract Component <: GenericComponent

  type TransceiverSimple <: Sensor
    coneAngle_deg::Float64
  end

  function getid(object::TransceiverSimple)
    return "TransceiverSimple"
  end

  function transceiversimple2xml(transceiverSimple::TransceiverSimple, parentNode::LightXML.XMLElement)
    sensor           = new_child(parentNode , "Sensor"     )
      id             = new_child(sensor     , "ID"         )
      transceiver    = new_child(sensor     , "Transceiver")
        simple       = new_child(transceiver, "Simple"     )
          cone_angle = new_child(simple     , "Cone_Angle" )
            value    = new_child(cone_angle , "Value"      )
            unit     = new_child(cone_angle , "Unit"       )

    add_text(id   , "TransceiverSimple"                 )
    add_text(value, "$(transceiverSimple.coneAngle_deg)")
    add_text(unit , "Degree"                            )

    return parentNode

  end

  type SatelliteBody <: Component
    mass_kg::Float64

    dimensionX_m::Float64
    dimensionY_m::Float64
    dimensionZ_m::Float64
  end

  function getid(object::SatelliteBody)
    return "SatelliteBody"
  end

  function satellitebody2xml(satelliteBody::SatelliteBody, parentNode::LightXML.XMLElement)
    component                     = new_child(parentNode, "Component"              )
      id                          = new_child(component , "ID"                     )
      auxiliary                   = new_child(component , "Auxiliary"              )
        total_mass                = new_child(auxiliary , "Total_Mass"             )
          value_mass              = new_child(total_mass, "Value"                  )
          unit_mass               = new_child(total_mass, "Unit"                   )
        dimensions                = new_child(auxiliary , "Dimensions"             )
          user_defined_dimensions = new_child(dimensions, "User_Defined_Dimensions")
          x                       = new_child(dimensions, "X"                      )
            value_x               = new_child(x         , "Value"                  )
            unit_x                = new_child(x         , "Unit"                   )
          y                       = new_child(dimensions, "Y"                      )
            value_y               = new_child(y         , "Value"                  )
            unit_y                = new_child(y         , "Unit"                   )
          z                       = new_child(dimensions, "Z"                      )
            value_z               = new_child(z         , "Value"                  )
            unit_z                = new_child(z         , "Unit"                   )
          shape                   = new_child(dimensions, "Shape"                  )

    add_text(id                     , "SatelliteBody"                )
    add_text(value_mass             , "$(satelliteBody.mass_kg)"     )
    add_text(unit_mass              , "Kilogram"                     )
    add_text(user_defined_dimensions, "true"                         )
    add_text(value_x                , "$(satelliteBody.dimensionX_m)")
    add_text(unit_x                 , "Meter"                        )
    add_text(value_y                , "$(satelliteBody.dimensionY_m)")
    add_text(unit_y                 , "Meter"                        )
    add_text(value_z                , "$(satelliteBody.dimensionZ_m)")
    add_text(unit_z                 , "Meter"                        )
    add_text(shape                  , "Box"                          )

    return parentNode

  end

  function earth2xml(parentNode::LightXML.XMLElement)
    celestial_body_definition      = new_child(parentNode               , "Celestial_Body_Definition")
      id                           = new_child(celestial_body_definition, "ID"                       )
      id_iau                       = new_child(celestial_body_definition, "ID_IAU"                   )
      shape                        = new_child(celestial_body_definition, "Shape"                    )
        sphere                     = new_child(shape                    , "Sphere"                   )
          radius                   = new_child(sphere                   , "Radius"                   )
            value_radius           = new_child(radius                   , "Value"                    )
            unit_radius            = new_child(radius                   , "Unit"                     )
      gravity                      = new_child(celestial_body_definition, "Gravity"                  )
    	  spherical                  = new_child(gravity                  , "Spherical"                )
          gravity_constant         = new_child(spherical                , "Gravity_Constant"         )
            value_gravity_constant = new_child(gravity_constant         , "Value"                    )
            unit_gravity_constant  = new_child(gravity_constant         , "Unit"                     )

    add_text(id                    , "Earth"                  )
    add_text(id_iau                , "Earth"                  )
    add_text(value_radius          , "6371.0"                 )
    add_text(unit_radius           , "Kilo-Meter"             )
    add_text(value_gravity_constant, "398600.435436"          )
    add_text(unit_gravity_constant , "Kilo-Meter**3/Second**2")

    return parentNode

  end

  function modeldata2xml(satelliteBody::SatelliteBody, transceiverSimpleList::Array{TransceiverSimple,1},astosScenarioFolderName::ASCIIString)
    xdoc  = XMLDocument()
    xroot = create_root(xdoc, "Models")
    set_attribute(xroot, "checkSum", "")

    earth2xml(xroot)
    satellitebody2xml(satelliteBody, xroot)
    for transceiver in transceiverSimpleList
      transceiversimple2xml(transceiver, xroot)
    end

    save_file(xdoc, astosScenarioFolderName*"\\model\\astos\\Model_Data.xml")
  end

  type AssemblyElement
    id               ::ASCIIString
    component        ::GenericComponent
    euler_Angle_1_deg::Float64
    euler_Angle_2_deg::Float64
    euler_Angle_3_deg::Float64
    sequence         ::ASCIIString

    AssemblyElement(id, component, euler_Angle_1, euler_Angle_2, euler_Angle_3, sequence) = (sequence in ["XYZ", "YZX", "ZXY", "ZYX", "XZY", "YXZ", "XYX", "XZX", "YXY", "YZY", "ZXZ", "ZYZ"])? new(id, component, euler_Angle_1, euler_Angle_2, euler_Angle_3, sequence) : error("Invalid sequence")
  end

  function assemblyelement2xml(assemblyElement::AssemblyElement, parentNode::LightXML.XMLElement)
    item                              = new_child(parentNode           , "Item"                         )
      id                              = new_child(item                 , "ID"                           )
      visual_representation           = new_child(item                 , "Visual_Representation"        )
        visual_representation_type    = new_child(visual_representation, "Visual_Representation_Type"   )
      class                           = new_child(item                 , "Class"                        )
      reference_element               = new_child(item                 , "Reference_Element"            )
      reference_node                  = new_child(item                 , "Reference_Node"               )
      anchor_node                     = new_child(item                 , "Anchor_Node"                  )
      pre_rotation_position           = new_child(item                 , "Pre_Rotation_Position"        )
        x                             = new_child(pre_rotation_position, "X"                            )
          value_x                     = new_child(x                    , "Value"                        )
          unit_x                      = new_child(x                    , "Unit"                         )
        y                             = new_child(pre_rotation_position, "Y"                            )
          value_y                     = new_child(y                    , "Value"                        )
          unit_y                      = new_child(y                    , "Unit"                         )
        z                             = new_child(pre_rotation_position, "Z"                            )
          value_z                     = new_child(z                    , "Value"                        )
          unit_z                      = new_child(z                    , "Unit"                         )
      nominal_orientation             = new_child(item                 , "Nominal_Orientation"          )
        sequence                      = new_child(nominal_orientation  , "Sequence"                     )
        euler_angle_1                 = new_child(nominal_orientation  , "Euler_Angle_1"                )
          value_euler_angle_1         = new_child(euler_angle_1        , "Value"                        )
          unit_euler_angle_1          = new_child(euler_angle_1        , "Unit"                         )
        euler_angle_2                 = new_child(nominal_orientation  , "Euler_Angle_2"                )
          value_euler_angle_2         = new_child(euler_angle_2        , "Value"                        )
          unit_euler_angle_2          = new_child(euler_angle_2        , "Unit"                         )
        euler_angle_3                 = new_child(nominal_orientation  , "Euler_Angle_3"                )
          value_euler_angle_3         = new_child(euler_angle_3        , "Value"                        )
          unit_euler_angle_3          = new_child(euler_angle_3        , "Unit"                         )
      degrees_of_freedom              = new_child(item                 , "Degrees_Of_Freedom"           )
        pre_rotation_position_offset  = new_child(degrees_of_freedom   , "Pre_Rotation_Position_Offset" )
        orientation_offset            = new_child(degrees_of_freedom   , "Orientation_Offset"           )
        post_rotation_position_offset = new_child(degrees_of_freedom   , "Post_Rotation_Position_Offset")
        rotation_sequence             = new_child(degrees_of_freedom   , "Rotation_Sequence"            )

    add_text(id                           , assemblyElement.id                    )
    add_text(visual_representation_type   , "Automatic_Generation"                )
    add_text(class                        , getid(assemblyElement.component)      )
    add_text(reference_element            , "Global"                              )
    add_text(reference_node               , "Center"                              )
    add_text(anchor_node                  , "Bottom"                              )
    add_text(value_x                      , "0.0"                                 )
    add_text( unit_x                      , "Meter"                               )
    add_text(value_y                      , "0.0"                                 )
    add_text( unit_y                      , "Meter"                               )
    add_text(value_z                      , "0.0"                                 )
    add_text( unit_z                      , "Meter"                               )
    add_text(sequence                     , assemblyElement.sequence              )
    add_text(value_euler_angle_1          , "$(assemblyElement.euler_Angle_1_deg)")
    add_text( unit_euler_angle_1          , "Degree"                              )
    add_text(value_euler_angle_2          , "$(assemblyElement.euler_Angle_2_deg)")
    add_text( unit_euler_angle_2          , "Degree"                              )
    add_text(value_euler_angle_3          , "$(assemblyElement.euler_Angle_3_deg)")
    add_text( unit_euler_angle_3          , "Degree"                              )
    add_text(pre_rotation_position_offset , "false"                               )
    add_text(orientation_offset           , "false"                               )
    add_text(post_rotation_position_offset, "false"                               )
    add_text(rotation_sequence            , "ZYX"                                 )

    return parentNode
  end

  type Assembly
    id::ASCIIString
    core::Array{AssemblyElement,1}
  end

  function assembly2xml(assembly::Assembly, parentNode::LightXML.XMLElement)
    item                             = new_child(parentNode           , "Item"                         )
      id                             = new_child(item                 , "ID"                           )
      core                           = new_child(item                 , "Core"                         )
        visual_representation        = new_child(core                 , "Visual_Representation"        )
          visual_representation_type = new_child(visual_representation, "Visual_Representation_Type"   )
        actuators                    = new_child(core                 , "Actuators"                    )
        components                   = new_child(core                 , "Components"                   )
        sensors                      = new_child(core                 , "Sensors"                      )

    add_text(id                        , assembly.id            )
    add_text(visual_representation_type, "Automatic_Generation" )

    for assemblyElement in assembly.core
      if isa(assemblyElement.component, Sensor)
        assemblyelement2xml(assemblyElement, sensors)
      elseif isa(assemblyElement.component, Component)
        assemblyelement2xml(assemblyElement, components)
      end
    end

    return parentNode
  end

  type Satellite
    satelliteBody  ::Assembly
    antennaFrontEnd::Assembly

    Satellite(satelliteBody::SatelliteBody, antennaFrontEnd::Assembly) = new(Assembly("Body",[AssemblyElement("Body", satelliteBody, 0, 0, 0, "ZYX")]), antennaFrontEnd)
  end

  function modeldefinition2xml(satelliteObj::Satellite, astosScenarioFolderName::ASCIIString)
    xdoc  = XMLDocument()

    xroot                                = create_root(xdoc               , "Model_Definition"          )
      default_environment                = new_child(xroot                , "Default_Environment"       )
        central_body                     = new_child(default_environment  , "Central_Body"              )
        gravitational_perturbation       = new_child(default_environment  , "Gravitational_Perturbation")
      celestial_bodies                   = new_child(xroot                , "Celestial_Bodies"          )
        item_celestial_bodies            = new_child(celestial_bodies     , "Item"                      )
      atmospheres                        = new_child(xroot                , "Atmospheres"               )
      hydrospheres                       = new_child(xroot                , "Hydrospheres"              )
	    winds                              = new_child(xroot                , "Winds"                     )
	    magnetic_fields                    = new_child(xroot                , "Magnetic_Fields"           )
      ephemeris_libraries                = new_child(xroot                , "Ephemeris_Libraries"       )
	    aero_configurations                = new_child(xroot                , "Aero_Configurations"       )
      constellations                     = new_child(xroot                , "Constellations"            )
		  vehicles                           = new_child(xroot                , "Vehicles"                  )
        item_vehicles                    = new_child(vehicles             , "Item"                      )
      entities_of_interest               = new_child(xroot                , "Entities_Of_Interest"      )
      catalogs                           = new_child(xroot                , "Catalogs"                  )
      entities                           = new_child(xroot                , "Entities"                  )
        item_entities                    = new_child(entities             , "Item"                      )
          id                             = new_child(item_entities        , "ID"                        )
          satellite                      = new_child(item_entities        , "Satellite"                 )
            visual_representation        = new_child(satellite            , "Visual_Representation"     )
              visual_representation_type = new_child(visual_representation, "Visual_Representation_Type")
            assemblies                   = new_child(satellite            , "Assemblies"                )
              assembly2xml(satelliteObj.antennaFrontEnd, assemblies)
              assembly2xml(satelliteObj.satelliteBody  , assemblies)

    set_attribute(xroot                , "checkSum", ""           )
    add_text(central_body              , "Earth"                  )
    add_text(gravitational_perturbation, ""                       )
    #add_text(celestial_bodies          , ""                       )
    add_text(item_celestial_bodies     , "Earth"                  )
    add_text(atmospheres               , ""                       )
    add_text(hydrospheres              , ""                       )
    add_text(winds                     , ""                       )
    add_text(magnetic_fields           , ""                       )
    add_text(ephemeris_libraries       , ""                       )
    add_text(aero_configurations       , ""                       )
    add_text(constellations            , ""                       )
    #add_text(vehicles                  , ""                       )
    add_text(item_vehicles             , "SatelliteBaseLineDesign")
    add_text(entities_of_interest      , ""                       )
    add_text(catalogs                  , ""                       )
    #add_text(entities                  , ""                       )
    #add_text(item_entities             , ""                       )
    add_text(id                        , "SatelliteBaseLineDesign")
    #add_text(satellite                 , ""                       )
    #add_text(visual_representation     , ""                       )
    add_text(visual_representation_type, "Automatic_Generation"   )
    #add_text(assemblies                , ""                       )


    save_file(xdoc, astosScenarioFolderName*"\\model\\astos\\Model_Definition.xml")
  end

end
