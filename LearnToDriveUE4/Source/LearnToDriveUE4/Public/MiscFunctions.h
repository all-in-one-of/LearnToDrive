// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "Engine.h"
#include "Engine/World.h"
#include "CoreMinimal.h"
#include "Kismet/BlueprintFunctionLibrary.h"
#include "MiscFunctions.generated.h"

/**
 * 
 */

// Wrap EWorldType::Type into blueprint exposed enumeration
UENUM(BlueprintType)
enum class EWorldPlayType : uint8
{
	None			UMETA(DisplayName = "None"),
	Game			UMETA(DisplayName = "Game"),
	Editor			UMETA(DisplayName = "Editor"),
	PIE				UMETA(DisplayName = "PIE"),
	EditorPreview	UMETA(DisplayName = "EditorPreview"),
	GamePreview		UMETA(DisplayName = "GamePreview"),
	GameRPC			UMETA(DisplayName = "GameRPC"),
	Inactive		UMETA(DisplayName = "Inactive")
};

UCLASS()
class LEARNTODRIVEUE4_API UMiscFunctions : public UBlueprintFunctionLibrary
{
	GENERATED_BODY()

		// Returns true if the game is currently running in standalone
		UFUNCTION(BlueprintPure, Category = "Engine")
		static bool IsInStandaloneWindow();

		// Returns the world type as a string
		UFUNCTION(BlueprintPure, Category = "Engine", meta = (WorldContext = "WorldContextObject"))
		static void GetWorldType(UObject* WorldContextObject, UPARAM(DisplayName = "World Play Type") EWorldPlayType& out);

};
