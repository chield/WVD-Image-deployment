#Create a gallery definition.
$imageResourceGroup = 'rg-weu-aib'
$location = 'westeurope'
$imageDefName = 'WVDImageForDemo'
$myGalleryName = 'WVDImageGalleryAIB'
$imageTemplateName = 'WVDWin10Image'
$runOutputName = 'WVDDistResults'
$identityNameResourceId = Get-Content Temp\identityNameId.txt

. Scripts\Get-AzureImageInfo.ps1
$info = Get-AzureImageInfo -Location $location

$ParamNewAzGalleryImageDefinition = @{
    GalleryName       = $myGalleryName
    ResourceGroupName = $imageResourceGroup
    Location          = $location
    Name              = $imageDefName
    OsState           = 'generalized'
    OsType            = 'Windows'
    Publisher         = $info.Publisher
    Offer             = $info.Offer
    Sku               = $info.Sku
}

$imageDef = New-AzGalleryImageDefinition @ParamNewAzGalleryImageDefinition

#########################################
#
# Create an image Builder Template
#
#########################################

#Create an Azure image builder source object

$SrcObjParams = @{
    SourceTypePlatformImage = $true
    Publisher               = $info.Publisher
    Offer                   = $info.Offer
    Sku                     = $info.Sku
    Version                 = 'latest'
}
$srcPlatform = New-AzImageBuilderSourceObject @SrcObjParams

#Create an Azure image builder customization object.

$ImgCustomParams = @{
    PowerShellCustomizer = $true
    CustomizerName       = 'settingUpMgmtAgtPath'
    RunElevated          = $false
    Inline               = @("mkdir c:\\buildActions", "echo Azure-Image-Builder-Was-Here  > c:\\buildActions\\buildActionsOutput.txt")
}
$Customizer = New-AzImageBuilderCustomizerObject @ImgCustomParams

#Create an Azure image builder distributor object.

$disObjParams = @{
    SharedImageDistributor = $true
    ArtifactTag            = @{tag = 'AIB Demo' }
    GalleryImageId         = $imageDef.Id
    ReplicationRegion      = $location
    RunOutputName          = $runOutputName
    ExcludeFromLatest      = $false
}
$disSharedImg = New-AzImageBuilderDistributorObject @disObjParams

#Create an Azure image builder template.

$ImgTemplateParams = @{
    ImageTemplateName      = $imageTemplateName
    ResourceGroupName      = $imageResourceGroup
    Source                 = $srcPlatform
    Distribute             = $disSharedImg
    Customize              = $Customizer
    Location               = $location
    UserAssignedIdentityId = $identityNameResourceId
}
New-AzImageBuilderTemplate @ImgTemplateParams