// Fill out your copyright notice in the Description page of Project Settings.

#include "MiscFunctions.h"

bool UMiscFunctions::IsInStandaloneWindow()
{
	if (GEngine != nullptr && GWorld != nullptr)
		return GEngine->GetNetMode(GWorld) == NM_Standalone;

	return false;
}

void UMiscFunctions::GetWorldType(UObject* WorldContextObject, UPARAM(DisplayName = "World Play Type") EWorldPlayType& out)
{
	UWorld* world = GEngine->GetWorldFromContextObject(WorldContextObject);

	if (world != nullptr) // Is valid?
	{
		EWorldType::Type worldType = world->WorldType;
		out = (EWorldPlayType)((uint8)worldType);
	}
	else
	{
		out = EWorldPlayType::None; // Default return value
	}
}