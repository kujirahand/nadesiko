
unit unit_exif_taglist;
interface
const
  F_IFD0   = 0;
  F_SubIFD = 1;
  F_IIFD   = 2;
  F_GpsIFD = 3;
  F_IFDx   = 4;
const
  F_EXIF_PLACE: array[0..178]of Integer = (
F_IFD0,F_IFD0,F_IFD0,F_IFD0,F_IFD0,F_IFD0,F_IFD0,F_IFD0,F_IFD0,F_IFD0,F_IFD0,F_IFD0,F_IFD0,F_IFD0,F_IFD0,F_IFD0,F_IFD0,F_IFD0,F_IFD0,F_IFD0,
F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,
F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,F_SubIFD,
F_IIFD,F_IIFD,F_IIFD,F_IIFD,F_IIFD,F_IIFD,F_IIFD,F_IIFD,F_IIFD,F_IIFD,F_IIFD,F_IIFD,F_IIFD,F_IIFD,F_IIFD,F_IIFD,F_IIFD,F_IIFD,F_IIFD,F_IIFD,F_IIFD,F_IIFD,F_IIFD,F_IIFD,F_IIFD,
F_GpsIFD,F_GpsIFD,F_GpsIFD,F_GpsIFD,F_GpsIFD,F_GpsIFD,F_GpsIFD,F_GpsIFD,F_GpsIFD,F_GpsIFD,F_GpsIFD,F_GpsIFD,F_GpsIFD,F_GpsIFD,F_GpsIFD,F_GpsIFD,F_GpsIFD,F_GpsIFD,F_GpsIFD,F_GpsIFD,F_GpsIFD,F_GpsIFD,F_GpsIFD,F_GpsIFD,F_GpsIFD,F_GpsIFD,F_GpsIFD,F_GpsIFD,F_GpsIFD,F_GpsIFD,F_GpsIFD,F_GpsIFD,
F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx,F_IFDx);
  F_EXIF_TAG  : array[0..178]of Integer = (
// IFD0(20)
$010e,$010f,$0110,$0112,$011a,$011b,$0128,$012d,$0131,$0132,$013b,$013e,$013f,$0211,$0213,$0214,$8298,$8769,$8825,$ea1c,
// SubIFD(Private Exif IFD)(39+26)
$829a,$829d,$8822,$8827,$9000,$9003,$9004,$9101,$9102,$9201,$9202,$9203,$9204,$9205,$9206,$9207,$9208,$9209,$920a,$927c,$9286,$9290,$9291,$9292,$a000,$a001,$a002,$a003,$a004,$a005,$a20e,$a20f,$a210,$a215,$a217,$a300,$a301,$a302,$ea1c,
$8830,$8831,$8832,$8833,$8834,$8835,$a401,$a402,$a403,$a404,$a405,$a406,$a407,$a408,$a409,$a40a,$a40b,$a40c,$a420,$a430,$a431,$a432,$a433,$a434,$a435,$a500,
// IIFD(25)
$0001,$0002,$1000,$1001,$1001,$0100,$0101,$0102,$0103,$0106,$0111,$0112,$0115,$0116,$0117,$011a,$011b,$011c,$0128,$0201,$0202,$0211,$0212,$0213,$0214,
// GpsIFD(IFD for GPS)(32)
$0000,$0001,$0002,$0003,$0004,$0005,$0006,$0007,$0008,$0009,$000a,$000b,$000c,$000d,$000e,$000f,$0010,$0011,$0012,$0013,$0014,$0015,$0016,$0017,$0018,$0019,$001a,$001b,$001c,$001d,$001e,$001f,
// IFDx(37)
$00fe,$00ff,$013d,$013e,$013f,$0142,$0143,$0144,$0145,$014a,$015b,$828d,$828e,$828f,$83bb,$8773,$8824,$8825,$8828,$8829,$882a,$882b,$920b,$920c,$920d,$9211,$9212,$9213,$9214,$9215,$9216,$9290,$9291,$9292,$a20b,$a20c,$a214);
  F_EXIF_TYPE : array[0..178]of Integer = (
// IFD0
2,2,2,3,5,5,3,3,2,2,2,5,5,5,3,5,2,4,4,7,
// SubIFD(Private Exif IFD)
5,5,3,3,7,2,2,7,5,10,5,10,10,5,10,3,3,3,5,7,7,2,2,2,7,3,4,4,2,4,5,5,3,5,3,7,7,7,7,
3,4,4,4,4,4,3,3,3,5,3,3,3,3,3,3,7,3,2,2,2,5,2,2,2,5,
// IIFD
2,7,2,9,9,4,4,3,3,3,4,3,3,4,4,5,5,3,3,4,4,5,3,3,5,
// GpsIFD
1,2,5,2,5,1,5,5,2,2,2,5,2,5,2,5,2,5,2,2,5,2,5,2,5,2,5,7,7,2,3,5,
// IFDx
4,3,3,5,5,3,3,4,3,4,7,3,1,5,4,7,2,4,7,3,8,3,5,7,7,4,2,2,3,5,1,2,2,2,5,3,3);
  F_EXIF_COUNT: array[0..178]of Integer = (
// IFD0
0,0,0,1,1,1,3,1,0,20,0,2,6,3,1,6,0,1,0,0,
// SubIFD(Private Exif IFD)
1,1,1,2,4,20,20,4,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,4,1,1,1,0,1,1,1,1,1,1,1,1,0,0,
1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,33,0,0,4,0,0,0,1,
// IIFD
4,4,0,1,1,1,1,3,1,1,0,1,1,1,0,1,1,1,1,1,1,3,2,1,6,
// GpsIFD
4,2,3,2,3,1,1,3,0,2,2,1,2,1,2,1,2,1,0,2,3,2,3,2,1,2,1,0,0,11,1,1,
// IFDx
1,1,1,2,6,1,1,0,0,0,0,2,0,1,0,0,0,1,0,1,1,1,1,0,0,1,1,0,4,1,4,0,0,0,1,1,1);
  F_EXIF_NAME : array[0..178]of String = (
// IFD0
'ImageDescription',
'Make',
'Model',
'Orientation',
'XResolution',
'YResolution',
'ResolutionUnit',
'TransferFunction',
'Software',
'DateTime',
'Artist',
'WhitePoint',
'PrimaryChromaticities',
'YCbCrCoefficients',
'YCbCrPositioning',
'ReferenceBlackWhite',
'Copyright',
'ExifIFDPointer',
'GPSInfoIFDPointer',
'Padding',

// SubIFD(Private Exif IFD)
'ExposureTime',
'FNumber',
'ExposureProgram',
'ISOSpeedRatings',
'ExifVersion',
'DateTimeOriginal',
'DateTimeDigitized',
'ComponentsConfiguration',
'CompressedBitsPerPixel',
'ShutterSpeedValue',
'ApertureValue',
'BrightnessValue',
'ExposureBiasValue',
'MaxApertureValue',
'SubjectDistance',
'MeteringMode',
'LightSource',
'Flash',
'FocalLength',
'MakerNote',
'UserComment',
'SubsecTime',
'SubsecTimeOriginal',
'SubsecTimeDigitized',
'FlashPixVersion',
'ColorSpace',
'ExifImageWidth',
'ExifImageHeight',
'RelatedSoundFile',
'InteroperabilityIFDPointer',
'FocalPlaneXResolution',
'FocalPlaneYResolution',
'FocalPlaneResolutionUnit',
'ExposureIndex',
'SensingMethod',
'FileSource',
'SceneType',
'CFAPattern',
'Padding',

'SensitivityType',
'StandardOutputSensitivity',
'RecommendedExposureIndex',
'ISOSpeed',
'ISOSpeedLatitydeyyy',
'ISOSpeedLatitudezzz',
'CustomRendered',
'ExposureMode',
'WhiteBalance',
'DigitalZoomRatio',
'FocalLengthIn35mmFilm',
'SceneCaptureType',
'GainControl',
'Contrast',
'Saturation',
'Sharpness',
'DeviceSettingDescription',
'SubjectDistanceRange',
'ImageUniqueID',
'CameraOwnerName',
'BodySerialNumber',
'LensSpecification',
'LensMake',
'LensModel',
'LensSerialNumber',
'Gamma',
// IIFD
'InteroperabilityIndex',
'InteroperabilityVersion',
'RelatedImageFileFormat',
'RelatedImageWidth',
'RelatedImageLength',
'ImageWidth',
'ImageLength',
'BitsPerSample',
'Compression',
'PhotometricInterpretation',
'StripOffsets',
'Orientation',
'SamplesPerPixel',
'RowsPerStrip',
'StripByteConunts',
'XResolution',
'YResolution',
'PlanarConfiguration',
'ResolutionUnit',
'JpegInterchangeFormat',
'JpegInterchangeFormatLength',
'YCbCrCoefficients',
'YCbCrSubSampling',
'YCbCrPositioning',
'ReferenceBlackWhite',

// GpsIFD
'GPSVersionID',
'GPSLatitudeRef',
'GPSLatitude',
'GPSLongitudeRef',
'GPSLongitude',
'GPSAltitudeRef',
'GPSAltitude',
'GPSTimeStamp',
'GPSSatellites',
'GPSStatus',
'GPSMeasureMode',
'GPSDOP',
'GPSSpeedRef',
'GPSSpeed',
'GPSTrackRef',
'GPSTrack',
'GPSImgDirectionRef',
'GPSImgDirection',
'GPSMapDatum',
'GPSDestLatitudeRef',
'GPSDestLatitude',
'GPSDestLongitudeRef',
'GPSDestLongitude',
'GPSDestBearingRef',
'GPSDestBearing',
'GPSDestDistanceRef',
'GPSDestDistance',
'GPSProcessingMethod',
'GPSAreaInformation',
'GPSDateStamp',
'GPSDifferential',
'GPSHPositioningError',

// IFDx
'NewSubfileType',
'SubfileType',
'Predictor',
'WhitePoint',
'PrimaryChromaticities',
'TileWidth',
'TileLength',
'TileOffsets',
'TileByteCounts',
'SubIFDs',
'JPEGTables',
'CFARepeatPatternDim',
'CFAPattern',
'BatteryLevel',
'IPTC/NAA',
'InterColorProfile',
'SpectralSensitivity',
'GPSInfo',
'OECF',
'Interlace',
'TimeZoneOffset',
'SelfTimerMode',
'FlashEnergy',
'SpatialFrequencyResponse',
'Noise',
'ImageNumber',
'SecurityClassification',
'ImageHistory',
'SubjectLocation',
'ExposureIndex',
'TIFF/EPStandardID',
'SubSecTime',
'SubSecTimeOriginal',
'SubSecTimeDigitized',
'FlashEnergy',
'SpatialFrequencyResponse',
'SubjectLocation');
const
  EXIFTAG_ImageDescription=$010e;
  EXIFTAG_Make=$010f;
  EXIFTAG_Model=$0110;
  EXIFTAG_Orientation=$0112;
  EXIFTAG_XResolution=$011a;
  EXIFTAG_YResolution=$011b;
  EXIFTAG_ResolutionUnit=$0128;
  EXIFTAG_Software=$0131;
  EXIFTAG_DateTime=$0132;
  EXIFTAG_WhitePoint=$013e;
  EXIFTAG_PrimaryChromaticities=$013f;
  EXIFTAG_YCbCrCoefficients=$0211;
  EXIFTAG_YCbCrPositioning=$0213;
  EXIFTAG_ReferenceBlackWhite=$0214;
  EXIFTAG_Copyright=$8298;
  EXIFTAG_ExifIFDPointer=$8769;
  EXIFTAG_ExposureTime=$829a;
  EXIFTAG_FNumber=$829d;
  EXIFTAG_ExposureProgram=$8822;
  EXIFTAG_ISOSpeedRatings=$8827;
  EXIFTAG_ExifVersion=$9000;
  EXIFTAG_DateTimeOriginal=$9003;
  EXIFTAG_DateTimeDigitized=$9004;
  EXIFTAG_ComponentsConfiguration=$9101;
  EXIFTAG_CompressedBitsPerPixel=$9102;
  EXIFTAG_ShutterSpeedValue=$9201;
  EXIFTAG_ApertureValue=$9202;
  EXIFTAG_BrightnessValue=$9203;
  EXIFTAG_ExposureBiasValue=$9204;
  EXIFTAG_MaxApertureValue=$9205;
  EXIFTAG_SubjectDistance=$9206;
  EXIFTAG_MeteringMode=$9207;
  EXIFTAG_LightSource=$9208;
  EXIFTAG_Flash=$9209;
  EXIFTAG_FocalLength=$920a;
  EXIFTAG_MakerNote=$927c;
  EXIFTAG_UserComment=$9286;
  EXIFTAG_SubsecTime=$9290;
  EXIFTAG_SubsecTimeOriginal=$9291;
  EXIFTAG_SubsecTimeDigitized=$9292;
  EXIFTAG_FlashPixVersion=$a000;
  EXIFTAG_ColorSpace=$a001;
  EXIFTAG_ExifImageWidth=$a002;
  EXIFTAG_ExifImageHeight=$a003;
  EXIFTAG_RelatedSoundFile=$a004;
  EXIFTAG_InteroperabilityIFDPointer=$a005;
  EXIFTAG_FocalPlaneXResolution=$a20e;
  EXIFTAG_FocalPlaneYResolution=$a20f;
  EXIFTAG_FocalPlaneResolutionUnit=$a210;
  EXIFTAG_ExposureIndex=$a215;
  EXIFTAG_SensingMethod=$a217;
  EXIFTAG_FileSource=$a300;
  EXIFTAG_SceneType=$a301;
  EXIFTAG_CFAPattern=$a302;
  EXIFTAG_InteroperabilityIndex=$0001;
  EXIFTAG_InteroperabilityVersion=$0002;
  EXIFTAG_RelatedImageFileFormat=$1000;
  EXIFTAG_RelatedImageWidth=$1001;
  EXIFTAG_ImageWidth=$0100;
  EXIFTAG_ImageLength=$0101;
  EXIFTAG_BitsPerSample=$0102;
  EXIFTAG_Compression=$0103;
  EXIFTAG_PhotometricInterpretation=$0106;
  EXIFTAG_StripOffsets=$0111;
  EXIFTAG_SamplesPerPixel=$0115;
  EXIFTAG_RowsPerStrip=$0116;
  EXIFTAG_StripByteConunts=$0117;
  EXIFTAG_PlanarConfiguration=$011c;
  EXIFTAG_JpegInterchangeFormat=$0201;
  EXIFTAG_JpegInterchangeFormatLength=$0202;
  EXIFTAG_YCbCrSubSampling=$0212;
  EXIFTAG_NewSubfileType=$00fe;
  EXIFTAG_SubfileType=$00ff;
  EXIFTAG_TransferFunction=$012d;
  EXIFTAG_Artist=$013b;
  EXIFTAG_Predictor=$013d;
  EXIFTAG_TileWidth=$0142;
  EXIFTAG_TileLength=$0143;
  EXIFTAG_TileOffsets=$0144;
  EXIFTAG_TileByteCounts=$0145;
  EXIFTAG_SubIFDs=$014a;
  EXIFTAG_JPEGTables=$015b;
  EXIFTAG_CFARepeatPatternDim=$828d;
  EXIFTAG_BatteryLevel=$828f;
  EXIFTAG_IPTC_NAA=$83bb;
  EXIFTAG_InterColorProfile=$8773;
  EXIFTAG_SpectralSensitivity=$8824;
  EXIFTAG_GPSInfo=$8825;
  EXIFTAG_OECF=$8828;
  EXIFTAG_Interlace=$8829;
  EXIFTAG_TimeZoneOffset=$882a;
  EXIFTAG_SelfTimerMode=$882b;
  EXIFTAG_FlashEnergy=$920b;
  EXIFTAG_SpatialFrequencyResponse=$920c;
  EXIFTAG_Noise=$920d;
  EXIFTAG_ImageNumber=$9211;
  EXIFTAG_SecurityClassification=$9212;
  EXIFTAG_ImageHistory=$9213;
  EXIFTAG_SubjectLocation=$9214;
  EXIFTAG_TIFF_EPStandardID=$9216;


implementation
end.
