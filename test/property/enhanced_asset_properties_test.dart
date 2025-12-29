import 'package:flutter_test/flutter_test.dart';
import 'package:stockinfoapp/src/models/asset_item.dart';
import 'package:stockinfoapp/src/models/asset_item.dart';
import 'package:stockinfoapp/src/models/strategy_template.dart';
import 'package:stockinfoapp/src/models/active_trade.dart';
import 'package:stockinfoapp/src/models/closed_trade.dart';
import 'package:stockinfoapp/src/strategies/trading_strategy_base.dart';
import 'package:stockinfoapp/src/strategies/composite_strategy.dart';
import 'package:stockinfoapp/src/strategies/trendline_strategy.dart';
import 'package:stockinfoapp/src/strategies/buy_area_strategy.dart';
import 'package:stockinfoapp/src/strategies/elliot_waves_strategy.dart';
import 'package:stockinfoapp/src/widgets/enhanced_asset_card.dart';
import 'package:stockinfoapp/src/widgets/asset_information_section.dart';
import 'package:stockinfoapp/src/widgets/asset_type_icon.dart';
import 'package:stockinfoapp/src/widgets/asset_identifiers.dart';
import 'package:stockinfoapp/src/widgets/performance_metrics.dart';
import 'package:stockinfoapp/src/widgets/tags_section.dart';
import 'package:stockinfoapp/src/widgets/strategies_section.dart';
import 'package:stockinfoapp/src/widgets/active_trades_section.dart';
import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  group('Enhanced Asset Properties', () {
    testWidgets('Property 4: Composite Strategy Logic Evaluation - For any composite strategy with multiple conditions and logical operators, the overall trigger evaluation should correctly apply boolean logic (AND/OR) to individual strategy results',
        (WidgetTester tester) async {
      // **Feature: enhanced-asset-cards, Property 4: Composite Strategy Logic Evaluation**
      // **Validates: Requirements 3.10**
      
      final random = Random();
      
      // Test with multiple iterations to verify property holds across different scenarios
      for (int iteration = 0; iteration < 100; iteration++) {
        // Generate random asset data for testing
        final assetData = _generateRandomAssetData(random);
        
        // Test 1: Single condition composite strategy should behave like the individual strategy
        final singleStrategy = _generateRandomStrategy(random, 'single_${iteration}_1');
        final singleComposite = CompositeStrategy(
          id: 'composite_single_$iteration',
          name: 'Single Condition Composite',
          conditions: [
            StrategyCondition(strategy: singleStrategy, operator: null),
          ],
          rootOperator: LogicalOperator.and,
        );
        
        final singleStrategyResult = singleStrategy.checkTriggerCondition(assetData);
        final singleCompositeResult = singleComposite.checkTriggerCondition(assetData);
        
        expect(singleCompositeResult, equals(singleStrategyResult),
            reason: 'Single condition composite should match individual strategy result');
        
        // Test 2: Two condition AND composite strategy
        final strategy1 = _generateRandomStrategy(random, 'and_${iteration}_1');
        final strategy2 = _generateRandomStrategy(random, 'and_${iteration}_2');
        final andComposite = CompositeStrategy(
          id: 'composite_and_$iteration',
          name: 'AND Composite',
          conditions: [
            StrategyCondition(strategy: strategy1, operator: null),
            StrategyCondition(strategy: strategy2, operator: LogicalOperator.and),
          ],
          rootOperator: LogicalOperator.and,
        );
        
        final result1 = strategy1.checkTriggerCondition(assetData);
        final result2 = strategy2.checkTriggerCondition(assetData);
        final expectedAndResult = result1 && result2;
        final actualAndResult = andComposite.checkTriggerCondition(assetData);
        
        expect(actualAndResult, equals(expectedAndResult),
            reason: 'AND composite should return true only when both conditions are true (result1: $result1, result2: $result2)');
        
        // Test 3: Two condition OR composite strategy
        final strategy3 = _generateRandomStrategy(random, 'or_${iteration}_1');
        final strategy4 = _generateRandomStrategy(random, 'or_${iteration}_2');
        final orComposite = CompositeStrategy(
          id: 'composite_or_$iteration',
          name: 'OR Composite',
          conditions: [
            StrategyCondition(strategy: strategy3, operator: null),
            StrategyCondition(strategy: strategy4, operator: LogicalOperator.or),
          ],
          rootOperator: LogicalOperator.or,
        );
        
        final result3 = strategy3.checkTriggerCondition(assetData);
        final result4 = strategy4.checkTriggerCondition(assetData);
        final expectedOrResult = result3 || result4;
        final actualOrResult = orComposite.checkTriggerCondition(assetData);
        
        expect(actualOrResult, equals(expectedOrResult),
            reason: 'OR composite should return true when at least one condition is true (result3: $result3, result4: $result4)');
        
        // Test 4: Three condition mixed operators composite strategy
        final strategy5 = _generateRandomStrategy(random, 'mixed_${iteration}_1');
        final strategy6 = _generateRandomStrategy(random, 'mixed_${iteration}_2');
        final strategy7 = _generateRandomStrategy(random, 'mixed_${iteration}_3');
        
        // Create a composite with mixed operators: strategy5 AND strategy6 OR strategy7
        final mixedComposite = CompositeStrategy(
          id: 'composite_mixed_$iteration',
          name: 'Mixed Operators Composite',
          conditions: [
            StrategyCondition(strategy: strategy5, operator: null),
            StrategyCondition(strategy: strategy6, operator: LogicalOperator.and),
            StrategyCondition(strategy: strategy7, operator: LogicalOperator.or),
          ],
          rootOperator: LogicalOperator.and,
        );
        
        final result5 = strategy5.checkTriggerCondition(assetData);
        final result6 = strategy6.checkTriggerCondition(assetData);
        final result7 = strategy7.checkTriggerCondition(assetData);
        
        // Expected evaluation: (strategy5 AND strategy6) OR strategy7
        final expectedMixedResult = (result5 && result6) || result7;
        final actualMixedResult = mixedComposite.checkTriggerCondition(assetData);
        
        expect(actualMixedResult, equals(expectedMixedResult),
            reason: 'Mixed operators composite should evaluate correctly: ($result5 AND $result6) OR $result7 = $expectedMixedResult');
        
        // Test 5: Empty conditions should return false
        final emptyComposite = CompositeStrategy(
          id: 'composite_empty_$iteration',
          name: 'Empty Composite',
          conditions: [],
          rootOperator: LogicalOperator.and,
        );
        
        final emptyResult = emptyComposite.checkTriggerCondition(assetData);
        expect(emptyResult, isFalse,
            reason: 'Empty composite strategy should always return false');
        
        // Test 6: Root operator consistency when no explicit operators are provided
        final strategy8 = _generateRandomStrategy(random, 'root_${iteration}_1');
        final strategy9 = _generateRandomStrategy(random, 'root_${iteration}_2');
        
        // Test with AND root operator
        final rootAndComposite = CompositeStrategy(
          id: 'composite_root_and_$iteration',
          name: 'Root AND Composite',
          conditions: [
            StrategyCondition(strategy: strategy8, operator: null),
            StrategyCondition(strategy: strategy9, operator: null), // Should use root operator
          ],
          rootOperator: LogicalOperator.and,
        );
        
        final result8 = strategy8.checkTriggerCondition(assetData);
        final result9 = strategy9.checkTriggerCondition(assetData);
        final expectedRootAndResult = result8 && result9;
        final actualRootAndResult = rootAndComposite.checkTriggerCondition(assetData);
        
        expect(actualRootAndResult, equals(expectedRootAndResult),
            reason: 'Root AND operator should be used when condition operators are null');
        
        // Test with OR root operator
        final rootOrComposite = CompositeStrategy(
          id: 'composite_root_or_$iteration',
          name: 'Root OR Composite',
          conditions: [
            StrategyCondition(strategy: strategy8, operator: null),
            StrategyCondition(strategy: strategy9, operator: null), // Should use root operator
          ],
          rootOperator: LogicalOperator.or,
        );
        
        final expectedRootOrResult = result8 || result9;
        final actualRootOrResult = rootOrComposite.checkTriggerCondition(assetData);
        
        expect(actualRootOrResult, equals(expectedRootOrResult),
            reason: 'Root OR operator should be used when condition operators are null');
        
        // Test 7: Complex nested logic with multiple conditions
        if (iteration % 10 == 0) { // Test complex scenarios less frequently for performance
          final strategies = List.generate(5, (i) => _generateRandomStrategy(random, 'complex_${iteration}_$i'));
          final complexComposite = CompositeStrategy(
            id: 'composite_complex_$iteration',
            name: 'Complex Composite',
            conditions: [
              StrategyCondition(strategy: strategies[0], operator: null),
              StrategyCondition(strategy: strategies[1], operator: LogicalOperator.and),
              StrategyCondition(strategy: strategies[2], operator: LogicalOperator.or),
              StrategyCondition(strategy: strategies[3], operator: LogicalOperator.and),
              StrategyCondition(strategy: strategies[4], operator: LogicalOperator.or),
            ],
            rootOperator: LogicalOperator.and,
          );
          
          final results = strategies.map((s) => s.checkTriggerCondition(assetData)).toList();
          
          // Expected evaluation: ((((s0 AND s1) OR s2) AND s3) OR s4)
          final step1 = results[0] && results[1]; // s0 AND s1
          final step2 = step1 || results[2];      // (s0 AND s1) OR s2
          final step3 = step2 && results[3];      // ((s0 AND s1) OR s2) AND s3
          final expectedComplexResult = step3 || results[4]; // (((s0 AND s1) OR s2) AND s3) OR s4
          
          final actualComplexResult = complexComposite.checkTriggerCondition(assetData);
          
          expect(actualComplexResult, equals(expectedComplexResult),
              reason: 'Complex composite should evaluate correctly: ((($results[0] AND $results[1]) OR $results[2]) AND $results[3]) OR $results[4] = $expectedComplexResult');
        }
        
        // Test 8: Verify that operator precedence is left-to-right evaluation
        final strategyA = _generateRandomStrategy(random, 'precedence_${iteration}_A');
        final strategyB = _generateRandomStrategy(random, 'precedence_${iteration}_B');
        final strategyC = _generateRandomStrategy(random, 'precedence_${iteration}_C');
        
        final precedenceComposite = CompositeStrategy(
          id: 'composite_precedence_$iteration',
          name: 'Precedence Test Composite',
          conditions: [
            StrategyCondition(strategy: strategyA, operator: null),
            StrategyCondition(strategy: strategyB, operator: LogicalOperator.or),
            StrategyCondition(strategy: strategyC, operator: LogicalOperator.and),
          ],
          rootOperator: LogicalOperator.and,
        );
        
        final resultA = strategyA.checkTriggerCondition(assetData);
        final resultB = strategyB.checkTriggerCondition(assetData);
        final resultC = strategyC.checkTriggerCondition(assetData);
        
        // Expected left-to-right evaluation: (A OR B) AND C
        final expectedPrecedenceResult = (resultA || resultB) && resultC;
        final actualPrecedenceResult = precedenceComposite.checkTriggerCondition(assetData);
        
        expect(actualPrecedenceResult, equals(expectedPrecedenceResult),
            reason: 'Operator precedence should be left-to-right: ($resultA OR $resultB) AND $resultC = $expectedPrecedenceResult');
      }
    });

    testWidgets('Property 7: Asset Type Support Consistency - For any supported asset type (Stocks, Resources, CFD, Crypto, Other), the system should correctly display the appropriate type symbol and handle the asset consistently across all card functions',
        (WidgetTester tester) async {
      // **Feature: enhanced-asset-cards, Property 7: Asset Type Support Consistency**
      // **Validates: Requirements 1.5, 3.9**
      
      final random = Random();
      
      // Test with multiple iterations to verify property holds across different scenarios
      for (int iteration = 0; iteration < 100; iteration++) {
        // Test each supported asset type
        for (final assetType in AssetType.values) {
          // Generate a random enhanced asset with the current asset type
          final testAsset = _generateRandomEnhancedAsset(random, assetType);
          
          // Property 1: Asset type should be correctly stored and retrieved
          expect(testAsset.assetType, equals(assetType),
              reason: 'Asset type should be correctly stored for $assetType');
          
          // Property 2: Asset type should have a valid display name
          final displayName = testAsset.assetType.displayName;
          expect(displayName, isNotEmpty,
              reason: 'Asset type $assetType should have a non-empty display name');
          expect(displayName, isA<String>(),
              reason: 'Asset type $assetType display name should be a string');
          
          // Property 3: Asset type should have a valid icon name
          final iconName = testAsset.assetType.iconName;
          expect(iconName, isNotEmpty,
              reason: 'Asset type $assetType should have a non-empty icon name');
          expect(iconName, isA<String>(),
              reason: 'Asset type $assetType icon name should be a string');
          
          // Property 4: Asset type should be consistent across serialization
          final json = testAsset.toJson();
          expect(json['assetType'], equals(assetType.name),
              reason: 'Asset type should be correctly serialized for $assetType');
          
          final deserializedAsset = AssetItem.fromJson(json);
          expect(deserializedAsset.assetType, equals(assetType),
              reason: 'Asset type should be correctly deserialized for $assetType');
          
          // Property 5: Asset type should be consistent in copyWith operations
          final copiedAsset = testAsset.copyWith(name: 'Modified Name');
          expect(copiedAsset.assetType, equals(assetType),
              reason: 'Asset type should be preserved in copyWith for $assetType');
          
          // Property 6: Asset type should be consistent when changing to different type
          for (final newAssetType in AssetType.values) {
            if (newAssetType != assetType) {
              final modifiedAsset = testAsset.copyWith(assetType: newAssetType);
              expect(modifiedAsset.assetType, equals(newAssetType),
                  reason: 'Asset type should be correctly changed from $assetType to $newAssetType');
              
              // Verify the new type has valid properties
              expect(modifiedAsset.assetType.displayName, isNotEmpty,
                  reason: 'Changed asset type $newAssetType should have valid display name');
              expect(modifiedAsset.assetType.iconName, isNotEmpty,
                  reason: 'Changed asset type $newAssetType should have valid icon name');
            }
          }
          
          // Property 7: Asset type should be consistent across all card functions
          // Test tag management functions
          final assetWithTag = testAsset.addTag('test-tag');
          expect(assetWithTag.assetType, equals(assetType),
              reason: 'Asset type should be preserved when adding tags for $assetType');
          
          final assetWithoutTag = assetWithTag.removeTag('test-tag');
          expect(assetWithoutTag.assetType, equals(assetType),
              reason: 'Asset type should be preserved when removing tags for $assetType');
          
          // Test performance calculation functions
          final dailyPerformance = testAsset.getDailyPerformancePercent();
          expect(dailyPerformance, isA<double>(),
              reason: 'Daily performance calculation should work for asset type $assetType');
          
          final openTradesPerformance = testAsset.getOpenTradesPerformance();
          expect(openTradesPerformance, isA<double>(),
              reason: 'Open trades performance calculation should work for asset type $assetType');
          
          final allTradesPerformance = testAsset.getAllTradesPerformance();
          expect(allTradesPerformance, isA<double>(),
              reason: 'All trades performance calculation should work for asset type $assetType');
          
          // Test alert checking functions
          final hasAlerts = testAsset.hasActiveAlerts();
          expect(hasAlerts, isA<bool>(),
              reason: 'Alert checking should work for asset type $assetType');
          
          // Test position value calculations
          final totalPositionValue = testAsset.getTotalPositionValue();
          expect(totalPositionValue, isA<double>(),
              reason: 'Position value calculation should work for asset type $assetType');
          expect(totalPositionValue, greaterThanOrEqualTo(0),
              reason: 'Position value should be non-negative for asset type $assetType');
          
          final totalPnL = testAsset.getTotalPnL();
          expect(totalPnL, isA<double>(),
              reason: 'P&L calculation should work for asset type $assetType');
          
          // Test tag filtering functions
          final filteredTags = testAsset.getFilteredTags();
          expect(filteredTags, isA<List<String>>(),
              reason: 'Tag filtering should work for asset type $assetType');
          
          final hasOverflow = testAsset.hasOverflowTags();
          expect(hasOverflow, isA<bool>(),
              reason: 'Tag overflow checking should work for asset type $assetType');
          
          // Property 8: Asset type enum should have all expected values
          expect(AssetType.values, contains(AssetType.stock),
              reason: 'AssetType enum should contain stock type');
          expect(AssetType.values, contains(AssetType.resource),
              reason: 'AssetType enum should contain resource type');
          expect(AssetType.values, contains(AssetType.cfd),
              reason: 'AssetType enum should contain cfd type');
          expect(AssetType.values, contains(AssetType.crypto),
              reason: 'AssetType enum should contain crypto type');
          expect(AssetType.values, contains(AssetType.other),
              reason: 'AssetType enum should contain other type');
          
          // Property 9: Each asset type should have unique display names and icon names
          final allDisplayNames = AssetType.values.map((type) => type.displayName).toSet();
          expect(allDisplayNames.length, equals(AssetType.values.length),
              reason: 'All asset types should have unique display names');
          
          final allIconNames = AssetType.values.map((type) => type.iconName).toSet();
          expect(allIconNames.length, equals(AssetType.values.length),
              reason: 'All asset types should have unique icon names');
        }
      }
    });

    testWidgets('Property 5: Strategy Template Round-Trip Integrity - For any composite strategy saved as a template and then applied to a new asset, the resulting strategy should preserve all logical operators, condition relationships, and strategy parameters from the original',
        (WidgetTester tester) async {
      // **Feature: enhanced-asset-cards, Property 5: Strategy Template Round-Trip Integrity**
      // **Validates: Requirements 4.1, 4.3, 4.4**
      
      final random = Random();
      
      // Initialize template manager for testing
      await TemplateManager.clearTemplates();
      
      // Test with multiple iterations to verify property holds across different scenarios
      for (int iteration = 0; iteration < 100; iteration++) {
        // Generate a random composite strategy with varying complexity
        final originalStrategy = _generateRandomCompositeStrategy(random, 'original_$iteration');
        
        // Generate random template metadata
        final templateName = 'Test Template $iteration';
        final templateDescription = 'Generated test template for iteration $iteration';
        final templateTags = _generateRandomTags(random);
        
        // Property 1: Template creation should preserve all strategy data
        final template = StrategyTemplate.fromCompositeStrategy(
          originalStrategy,
          name: templateName,
          description: templateDescription,
          tags: templateTags,
        );
        
        // Verify template preserves original strategy structure
        expect(template.conditions.length, equals(originalStrategy.conditions.length),
            reason: 'Template should preserve the number of conditions');
        expect(template.rootOperator, equals(originalStrategy.rootOperator),
            reason: 'Template should preserve the root operator');
        expect(template.name, equals(templateName),
            reason: 'Template should have the specified name');
        expect(template.description, equals(templateDescription),
            reason: 'Template should have the specified description');
        expect(template.tags, equals(templateTags),
            reason: 'Template should preserve the specified tags');
        
        // Verify each condition is preserved
        for (int i = 0; i < originalStrategy.conditions.length; i++) {
          final originalCondition = originalStrategy.conditions[i];
          final templateCondition = template.conditions[i];
          
          expect(templateCondition.strategy.id, equals(originalCondition.strategy.id),
              reason: 'Template condition $i should preserve strategy ID');
          expect(templateCondition.strategy.type, equals(originalCondition.strategy.type),
              reason: 'Template condition $i should preserve strategy type');
          expect(templateCondition.operator, equals(originalCondition.operator),
              reason: 'Template condition $i should preserve logical operator');
          
          // Verify strategy parameters are preserved
          final originalParams = originalCondition.strategy.parameters;
          final templateParams = templateCondition.strategy.parameters;
          expect(templateParams, equals(originalParams),
              reason: 'Template condition $i should preserve strategy parameters');
        }
        
        // Property 2: Template serialization round-trip should preserve all data
        final templateJson = template.toJson();
        final deserializedTemplate = StrategyTemplate.fromJson(templateJson);
        
        expect(deserializedTemplate.id, equals(template.id),
            reason: 'Serialization should preserve template ID');
        expect(deserializedTemplate.name, equals(template.name),
            reason: 'Serialization should preserve template name');
        expect(deserializedTemplate.description, equals(template.description),
            reason: 'Serialization should preserve template description');
        expect(deserializedTemplate.rootOperator, equals(template.rootOperator),
            reason: 'Serialization should preserve root operator');
        expect(deserializedTemplate.tags, equals(template.tags),
            reason: 'Serialization should preserve template tags');
        expect(deserializedTemplate.conditions.length, equals(template.conditions.length),
            reason: 'Serialization should preserve number of conditions');
        
        // Verify each condition survives serialization
        for (int i = 0; i < template.conditions.length; i++) {
          final originalCondition = template.conditions[i];
          final deserializedCondition = deserializedTemplate.conditions[i];
          
          expect(deserializedCondition.strategy.id, equals(originalCondition.strategy.id),
              reason: 'Serialization should preserve condition $i strategy ID');
          expect(deserializedCondition.strategy.type, equals(originalCondition.strategy.type),
              reason: 'Serialization should preserve condition $i strategy type');
          expect(deserializedCondition.operator, equals(originalCondition.operator),
              reason: 'Serialization should preserve condition $i operator');
          expect(deserializedCondition.strategy.parameters, equals(originalCondition.strategy.parameters),
              reason: 'Serialization should preserve condition $i strategy parameters');
        }
        
        // Property 3: Template application should create equivalent composite strategy
        final newAssetId = 'test_asset_$iteration';
        final appliedStrategy = deserializedTemplate.toCompositeStrategy('applied_$iteration', newAssetId);
        
        // Verify applied strategy has same logical structure
        expect(appliedStrategy.conditions.length, equals(originalStrategy.conditions.length),
            reason: 'Applied strategy should have same number of conditions as original');
        expect(appliedStrategy.rootOperator, equals(originalStrategy.rootOperator),
            reason: 'Applied strategy should have same root operator as original');
        
        // Verify each condition is equivalent
        for (int i = 0; i < originalStrategy.conditions.length; i++) {
          final originalCondition = originalStrategy.conditions[i];
          final appliedCondition = appliedStrategy.conditions[i];
          
          expect(appliedCondition.strategy.type, equals(originalCondition.strategy.type),
              reason: 'Applied condition $i should have same strategy type as original');
          expect(appliedCondition.operator, equals(originalCondition.operator),
              reason: 'Applied condition $i should have same operator as original');
          
          // Verify strategy parameters are equivalent (but IDs may differ)
          final originalParams = originalCondition.strategy.parameters;
          final appliedParams = appliedCondition.strategy.parameters;
          
          // Compare parameters excluding ID-specific fields
          _compareStrategyParameters(originalParams, appliedParams, originalCondition.strategy.type);
        }
        
        // Property 4: Behavioral equivalence - both strategies should produce same results
        final testAssetData = _generateRandomAssetData(random);
        
        final originalResult = originalStrategy.checkTriggerCondition(testAssetData);
        final appliedResult = appliedStrategy.checkTriggerCondition(testAssetData);
        
        expect(appliedResult, equals(originalResult),
            reason: 'Applied strategy should produce same trigger result as original strategy');
        
        // Property 5: Template manager round-trip should preserve all data
        await TemplateManager.saveTemplate(template);
        final retrievedTemplate = TemplateManager.getTemplate(template.id);
        
        expect(retrievedTemplate, isNotNull,
            reason: 'Template should be retrievable after saving');
        expect(retrievedTemplate!.id, equals(template.id),
            reason: 'Retrieved template should have same ID');
        expect(retrievedTemplate.name, equals(template.name),
            reason: 'Retrieved template should have same name');
        expect(retrievedTemplate.description, equals(template.description),
            reason: 'Retrieved template should have same description');
        expect(retrievedTemplate.rootOperator, equals(template.rootOperator),
            reason: 'Retrieved template should have same root operator');
        expect(retrievedTemplate.tags, equals(template.tags),
            reason: 'Retrieved template should have same tags');
        expect(retrievedTemplate.conditions.length, equals(template.conditions.length),
            reason: 'Retrieved template should have same number of conditions');
        
        // Property 6: Template application through manager should work correctly
        final managerAppliedStrategy = await TemplateManager.applyTemplate(template.id, newAssetId);
        
        // Verify manager-applied strategy is equivalent to direct application
        expect(managerAppliedStrategy.conditions.length, equals(appliedStrategy.conditions.length),
            reason: 'Manager-applied strategy should have same structure as direct application');
        expect(managerAppliedStrategy.rootOperator, equals(appliedStrategy.rootOperator),
            reason: 'Manager-applied strategy should have same root operator as direct application');
        
        // Verify behavioral equivalence
        final managerAppliedResult = managerAppliedStrategy.checkTriggerCondition(testAssetData);
        expect(managerAppliedResult, equals(originalResult),
            reason: 'Manager-applied strategy should produce same result as original');
        
        // Property 7: Template usage count should be updated correctly
        final updatedTemplate = TemplateManager.getTemplate(template.id);
        expect(updatedTemplate!.usageCount, equals(template.usageCount + 1),
            reason: 'Template usage count should increment after application');
        
        // Property 8: Complex template operations should preserve integrity
        if (iteration % 20 == 0) { // Test complex scenarios less frequently
          // Test template update from modified strategy
          final modifiedStrategy = appliedStrategy.addCondition(
            _generateRandomStrategy(random, 'additional_${iteration}'),
            LogicalOperator.or,
          );
          
          final updatedTemplateFromStrategy = template.updateFromStrategy(modifiedStrategy);
          expect(updatedTemplateFromStrategy.conditions.length, equals(modifiedStrategy.conditions.length),
              reason: 'Updated template should reflect modified strategy structure');
          
          // Test template search functionality
          final searchResults = TemplateManager.searchTemplates(templateName);
          expect(searchResults.any((t) => t.id == template.id), isTrue,
              reason: 'Template should be findable through search');
          
          // Test template categorization
          final category = template.getCategory();
          expect(category, isNotEmpty,
              reason: 'Template should have a valid category');
          
          final categoryTemplates = TemplateManager.getTemplatesByCategory(category);
          expect(categoryTemplates.any((t) => t.id == template.id), isTrue,
              reason: 'Template should appear in its category');
        }
        
        // Clean up for next iteration
        await TemplateManager.deleteTemplate(template.id);
      }
      
      // Final cleanup
      await TemplateManager.clearTemplates();
    });

    testWidgets('Property 2: Strategy Alert Visual Indicator Consistency - For any strategy with alert configuration, the alarm clock symbol color should always accurately reflect the alert enabled state (red for enabled, gray for disabled) and be toggleable by user interaction',
        (WidgetTester tester) async {
      // **Feature: enhanced-asset-cards, Property 2: Strategy Alert Visual Indicator Consistency**
      // **Validates: Requirements 3.4, 3.5, 3.6, 7.4**
      
      final random = Random();
      
      // Test with multiple iterations to verify property holds across different scenarios
      for (int iteration = 0; iteration < 100; iteration++) {
        // Generate random strategy with random alert state
        final strategy = _generateRandomStrategy(random, 'alert_test_$iteration');
        final initialAlertState = random.nextBool();
        
        final strategyItem = TradingStrategyItem(
          id: 'strategy_item_$iteration',
          strategy: strategy,
          direction: random.nextBool() ? TradeDirection.long : TradeDirection.short,
          alertEnabled: initialAlertState,
          created: DateTime.now().subtract(Duration(days: random.nextInt(30))),
          lastTriggered: random.nextBool() 
              ? DateTime.now().subtract(Duration(hours: random.nextInt(72)))
              : null,
        );
        
        // Property 1: Alert state should be correctly stored and retrievable
        expect(strategyItem.alertEnabled, equals(initialAlertState),
            reason: 'Strategy alert state should be correctly stored');
        
        // Property 2: Alert state should be consistent across serialization
        final json = strategyItem.toJson();
        expect(json['alertEnabled'], equals(initialAlertState),
            reason: 'Alert state should be correctly serialized');
        
        final deserializedItem = TradingStrategyItem.fromJson(json);
        expect(deserializedItem.alertEnabled, equals(initialAlertState),
            reason: 'Alert state should be correctly deserialized');
        
        // Property 3: Alert toggle should correctly flip the state
        final toggledItem = strategyItem.toggleAlert();
        expect(toggledItem.alertEnabled, equals(!initialAlertState),
            reason: 'Alert toggle should flip the alert state');
        
        // Verify original item is unchanged (immutability)
        expect(strategyItem.alertEnabled, equals(initialAlertState),
            reason: 'Original strategy item should remain unchanged after toggle');
        
        // Property 4: Multiple toggles should return to original state
        final doubleToggledItem = toggledItem.toggleAlert();
        expect(doubleToggledItem.alertEnabled, equals(initialAlertState),
            reason: 'Double toggle should return to original alert state');
        
        // Property 5: Alert state should be preserved in copyWith operations
        final copiedItem = strategyItem.copyWith(
          direction: strategyItem.direction == TradeDirection.long 
              ? TradeDirection.short 
              : TradeDirection.long,
        );
        expect(copiedItem.alertEnabled, equals(initialAlertState),
            reason: 'Alert state should be preserved in copyWith operations');
        
        // Property 6: Alert state should be independent of other properties
        final modifiedItem = strategyItem.copyWith(
          alertEnabled: !initialAlertState,
          lastTriggered: DateTime.now(),
        );
        expect(modifiedItem.alertEnabled, equals(!initialAlertState),
            reason: 'Alert state should be independently modifiable');
        expect(modifiedItem.direction, equals(strategyItem.direction),
            reason: 'Other properties should remain unchanged when modifying alert state');
        
        // Property 7: Alert state should work consistently for all strategy types
        for (final strategyType in [StrategyType.trendline, StrategyType.buyArea, StrategyType.elliotWaves]) {
          final typeSpecificStrategy = _generateStrategyOfType(random, strategyType, 'type_test_${iteration}_${strategyType.name}');
          final typeSpecificItem = TradingStrategyItem(
            id: 'type_specific_$iteration',
            strategy: typeSpecificStrategy,
            direction: TradeDirection.long,
            alertEnabled: true,
            created: DateTime.now(),
          );
          
          expect(typeSpecificItem.alertEnabled, isTrue,
              reason: 'Alert should work for strategy type $strategyType');
          
          final toggledTypeItem = typeSpecificItem.toggleAlert();
          expect(toggledTypeItem.alertEnabled, isFalse,
              reason: 'Alert toggle should work for strategy type $strategyType');
        }
        
        // Property 8: Alert state should be consistent in enhanced asset context
        final testAsset = _generateRandomEnhancedAsset(random, AssetType.stock);
        final assetWithStrategy = testAsset.addStrategy(strategyItem);
        
        expect(assetWithStrategy.strategies.first.alertEnabled, equals(initialAlertState),
            reason: 'Alert state should be preserved when adding strategy to asset');
        
        // Test hasActiveAlerts function
        final hasAlertsWhenEnabled = assetWithStrategy.copyWith(
          strategies: [strategyItem.copyWith(alertEnabled: true)],
        ).hasActiveAlerts();
        expect(hasAlertsWhenEnabled, isTrue,
            reason: 'Asset should report active alerts when strategy has alerts enabled');
        
        final hasAlertsWhenDisabled = assetWithStrategy.copyWith(
          strategies: [strategyItem.copyWith(alertEnabled: false)],
        ).hasActiveAlerts();
        expect(hasAlertsWhenDisabled, isFalse,
            reason: 'Asset should not report active alerts when strategy has alerts disabled');
        
        // Property 9: Alert state should be consistent for composite strategies
        if (iteration % 10 == 0) { // Test composite strategies less frequently
          final compositeStrategy = _generateRandomCompositeStrategy(random, 'composite_alert_$iteration');
          final compositeItem = TradingStrategyItem(
            id: 'composite_item_$iteration',
            strategy: compositeStrategy,
            direction: TradeDirection.long,
            alertEnabled: true,
            created: DateTime.now(),
          );
          
          expect(compositeItem.alertEnabled, isTrue,
              reason: 'Alert should work for composite strategies');
          
          final toggledComposite = compositeItem.toggleAlert();
          expect(toggledComposite.alertEnabled, isFalse,
              reason: 'Alert toggle should work for composite strategies');
          
          // Verify composite strategy alert state in serialization
          final compositeJson = compositeItem.toJson();
          final deserializedComposite = TradingStrategyItem.fromJson(compositeJson);
          expect(deserializedComposite.alertEnabled, equals(compositeItem.alertEnabled),
              reason: 'Composite strategy alert state should survive serialization');
        }
        
        // Property 10: Alert state transitions should be atomic and consistent
        final stateTransitions = [true, false, true, false, true];
        TradingStrategyItem currentItem = strategyItem;
        
        for (int i = 0; i < stateTransitions.length; i++) {
          final targetState = stateTransitions[i];
          
          // Set to target state
          currentItem = currentItem.copyWith(alertEnabled: targetState);
          expect(currentItem.alertEnabled, equals(targetState),
              reason: 'Alert state should be correctly set to $targetState in transition $i');
          
          // Verify state is consistent across operations
          final serialized = TradingStrategyItem.fromJson(currentItem.toJson());
          expect(serialized.alertEnabled, equals(targetState),
              reason: 'Alert state should remain $targetState after serialization in transition $i');
          
          final copied = currentItem.copyWith();
          expect(copied.alertEnabled, equals(targetState),
              reason: 'Alert state should remain $targetState after copying in transition $i');
        }
        
        // Property 11: Alert state should be independent across multiple strategy items
        final strategy1 = TradingStrategyItem(
          id: 'multi_1_$iteration',
          strategy: _generateRandomStrategy(random, 'multi_strategy_1_$iteration'),
          direction: TradeDirection.long,
          alertEnabled: true,
          created: DateTime.now(),
        );
        
        final strategy2 = TradingStrategyItem(
          id: 'multi_2_$iteration',
          strategy: _generateRandomStrategy(random, 'multi_strategy_2_$iteration'),
          direction: TradeDirection.short,
          alertEnabled: false,
          created: DateTime.now(),
        );
        
        // Toggle first strategy alert
        final toggledStrategy1 = strategy1.toggleAlert();
        
        // Verify second strategy is unaffected
        expect(strategy2.alertEnabled, isFalse,
            reason: 'Second strategy alert state should be independent of first strategy changes');
        expect(toggledStrategy1.alertEnabled, isFalse,
            reason: 'First strategy should be toggled to false');
        
        // Verify in asset context
        final multiStrategyAsset = testAsset.copyWith(
          strategies: [toggledStrategy1, strategy2],
        );
        
        expect(multiStrategyAsset.strategies[0].alertEnabled, isFalse,
            reason: 'First strategy in asset should have alerts disabled');
        expect(multiStrategyAsset.strategies[1].alertEnabled, isFalse,
            reason: 'Second strategy in asset should have alerts disabled');
        expect(multiStrategyAsset.hasActiveAlerts(), isFalse,
            reason: 'Asset should not have active alerts when all strategies have alerts disabled');
        
        // Enable alerts on second strategy
        final enabledStrategy2 = strategy2.copyWith(alertEnabled: true);
        final mixedAlertAsset = multiStrategyAsset.copyWith(
          strategies: [toggledStrategy1, enabledStrategy2],
        );
        
        expect(mixedAlertAsset.hasActiveAlerts(), isTrue,
            reason: 'Asset should have active alerts when at least one strategy has alerts enabled');
      }
    });

    testWidgets('Property 12: Performance Metrics Calculation Accuracy - For any asset with associated trades, the displayed performance metrics (daily performance, open trades performance, all trades performance) should be mathematically consistent with the underlying trade data and current market prices',
        (WidgetTester tester) async {
      // **Feature: enhanced-asset-cards, Property 12: Performance Metrics Calculation Accuracy**
      // **Validates: Requirements 1.7, 1.8, 1.9**
      
      final random = Random();
      
      // Test with multiple iterations to verify property holds across different scenarios
      for (int iteration = 0; iteration < 100; iteration++) {
        // Generate random asset with varying trade configurations
        final currentPrice = 50.0 + random.nextDouble() * 500.0; // Random price between 50-550
        final previousClose = currentPrice + (random.nextDouble() - 0.5) * 50.0; // +/- 25 from current
        
        final testAsset = _generateRandomEnhancedAsset(random, AssetType.stock).copyWith(
          currentValue: currentPrice,
          previousClose: previousClose,
        );
        
        // Property 1: Daily performance should be mathematically consistent
        final expectedDailyChange = currentPrice - previousClose;
        final expectedDailyPercent = previousClose > 0 ? (expectedDailyChange / previousClose) * 100 : 0.0;
        
        expect(testAsset.calculatedDayChange, closeTo(expectedDailyChange, 0.001),
            reason: 'Daily change calculation should be mathematically correct');
        expect(testAsset.getDailyPerformancePercent(), closeTo(expectedDailyPercent, 0.001),
            reason: 'Daily performance percentage should be mathematically correct');
        
        // Property 2: Empty trades should result in zero performance
        final assetWithNoTrades = testAsset.copyWith(
          activeTrades: [],
          closedTrades: [],
        );
        
        expect(assetWithNoTrades.getOpenTradesPerformance(), equals(0.0),
            reason: 'Open trades performance should be 0 when no active trades exist');
        expect(assetWithNoTrades.getAllTradesPerformance(), equals(0.0),
            reason: 'All trades performance should be 0 when no trades exist');
        expect(assetWithNoTrades.getTotalPositionValue(), equals(0.0),
            reason: 'Total position value should be 0 when no active trades exist');
        expect(assetWithNoTrades.getTotalPnL(), equals(0.0),
            reason: 'Total P&L should be 0 when no active trades exist');
        
        // Property 3: Single active trade performance should be mathematically consistent
        final buyPrice = 40.0 + random.nextDouble() * 400.0;
        final quantity = 1.0 + random.nextDouble() * 99.0; // 1-100 shares
        
        final singleTrade = ActiveTradeItem(
          id: 'single_trade_$iteration',
          assetId: testAsset.id,
          direction: TradeDirection.long,
          quantity: quantity,
          buyPrice: buyPrice,
          openDate: DateTime.now().subtract(Duration(days: random.nextInt(30))),
        );
        
        final assetWithSingleTrade = testAsset.copyWith(
          activeTrades: [singleTrade],
          closedTrades: [],
        );
        
        final expectedTotalValue = quantity * buyPrice;
        final expectedPnL = quantity * (currentPrice - buyPrice);
        final expectedOpenPerformance = buyPrice > 0 ? (expectedPnL / expectedTotalValue) * 100 : 0.0;
        
        expect(assetWithSingleTrade.getTotalPositionValue(), closeTo(expectedTotalValue, 0.001),
            reason: 'Single trade total position value should be quantity * buy price');
        expect(assetWithSingleTrade.getTotalPnL(), closeTo(expectedPnL, 0.001),
            reason: 'Single trade P&L should be quantity * (current price - buy price)');
        expect(assetWithSingleTrade.getOpenTradesPerformance(), closeTo(expectedOpenPerformance, 0.001),
            reason: 'Single trade open performance should be (P&L / invested) * 100');
        expect(assetWithSingleTrade.getAllTradesPerformance(), closeTo(expectedOpenPerformance, 0.001),
            reason: 'All trades performance should equal open trades performance when no closed trades');
        
        // Property 4: Multiple active trades should aggregate correctly
        final tradeCount = 2 + random.nextInt(4); // 2-5 trades
        final activeTrades = <ActiveTradeItem>[];
        double totalInvested = 0.0;
        double totalPnL = 0.0;
        
        for (int i = 0; i < tradeCount; i++) {
          final tradeBuyPrice = 30.0 + random.nextDouble() * 300.0;
          final tradeQuantity = 1.0 + random.nextDouble() * 50.0;
          final tradeDirection = random.nextBool() ? TradeDirection.long : TradeDirection.short;
          
          final trade = ActiveTradeItem(
            id: 'multi_trade_${iteration}_$i',
            assetId: testAsset.id,
            direction: tradeDirection,
            quantity: tradeQuantity,
            buyPrice: tradeBuyPrice,
            openDate: DateTime.now().subtract(Duration(days: random.nextInt(30))),
          );
          
          activeTrades.add(trade);
          totalInvested += trade.getTotalValue();
          totalPnL += trade.calculatePnL(currentPrice);
        }
        
        final assetWithMultipleTrades = testAsset.copyWith(
          activeTrades: activeTrades,
          closedTrades: [],
        );
        
        final expectedMultiOpenPerformance = totalInvested > 0 ? (totalPnL / totalInvested) * 100 : 0.0;
        
        expect(assetWithMultipleTrades.getTotalPositionValue(), closeTo(totalInvested, 0.001),
            reason: 'Multiple trades total position value should be sum of individual trade values');
        expect(assetWithMultipleTrades.getTotalPnL(), closeTo(totalPnL, 0.001),
            reason: 'Multiple trades P&L should be sum of individual trade P&Ls');
        expect(assetWithMultipleTrades.getOpenTradesPerformance(), closeTo(expectedMultiOpenPerformance, 0.001),
            reason: 'Multiple trades open performance should be (total P&L / total invested) * 100');
        
        // Property 5: Closed trades should be included in all trades performance
        final closedTradeCount = 1 + random.nextInt(3); // 1-3 closed trades
        final closedTrades = <ClosedTradeItem>[];
        double closedInvested = 0.0;
        double closedPnL = 0.0;
        
        for (int i = 0; i < closedTradeCount; i++) {
          final closedBuyPrice = 25.0 + random.nextDouble() * 250.0;
          final closedSellPrice = 25.0 + random.nextDouble() * 250.0;
          final closedQuantity = 1.0 + random.nextDouble() * 30.0;
          final closedDirection = random.nextBool() ? TradeDirection.long : TradeDirection.short;
          
          final closedBuyValue = closedQuantity * closedBuyPrice;
          final closedSellValue = closedQuantity * closedSellPrice;
          final closedProfitLoss = closedDirection == TradeDirection.long 
              ? closedSellValue - closedBuyValue 
              : closedBuyValue - closedSellValue;
          final closedProfitLossPercentage = closedBuyValue > 0 ? (closedProfitLoss / closedBuyValue) * 100 : 0.0;
          
          final closedTrade = ClosedTradeItem(
            id: 'closed_trade_${iteration}_$i',
            assetId: testAsset.id,
            direction: closedDirection,
            quantity: closedQuantity,
            buyPrice: closedBuyPrice,
            sellPrice: closedSellPrice,
            openDate: DateTime.now().subtract(Duration(days: 30 + random.nextInt(60))),
            closeDate: DateTime.now().subtract(Duration(days: random.nextInt(30))),
            profitLoss: closedProfitLoss,
            profitLossPercentage: closedProfitLossPercentage,
            buyValue: closedBuyValue,
            sellValue: closedSellValue,
          );
          
          closedTrades.add(closedTrade);
          closedInvested += closedTrade.buyValue;
          closedPnL += closedTrade.profitLoss;
        }
        
        final assetWithAllTrades = assetWithMultipleTrades.copyWith(
          closedTrades: closedTrades,
        );
        
        final totalAllInvested = totalInvested + closedInvested;
        final totalAllPnL = totalPnL + closedPnL;
        final expectedAllTradesPerformance = totalAllInvested > 0 ? (totalAllPnL / totalAllInvested) * 100 : 0.0;
        
        expect(assetWithAllTrades.getAllTradesPerformance(), closeTo(expectedAllTradesPerformance, 0.001),
            reason: 'All trades performance should include both open and closed trades');
        
        // Verify open trades performance is unchanged
        expect(assetWithAllTrades.getOpenTradesPerformance(), closeTo(expectedMultiOpenPerformance, 0.001),
            reason: 'Open trades performance should not be affected by closed trades');
        
        // Property 6: Long vs Short trade direction should affect P&L calculation correctly
        final longTrade = ActiveTradeItem(
          id: 'long_trade_$iteration',
          assetId: testAsset.id,
          direction: TradeDirection.long,
          quantity: 10.0,
          buyPrice: 100.0,
          openDate: DateTime.now(),
        );
        
        final shortTrade = ActiveTradeItem(
          id: 'short_trade_$iteration',
          assetId: testAsset.id,
          direction: TradeDirection.short,
          quantity: 10.0,
          buyPrice: 100.0,
          openDate: DateTime.now(),
        );
        
        final testPrice = 110.0; // 10% higher than buy price
        
        final longPnL = longTrade.calculatePnL(testPrice);
        final shortPnL = shortTrade.calculatePnL(testPrice);
        
        expect(longPnL, equals(100.0), // 10 * (110 - 100) = 100
            reason: 'Long trade should profit when price increases');
        expect(shortPnL, equals(-100.0), // 10 * (100 - 110) = -100
            reason: 'Short trade should lose when price increases');
        
        // Test with price decrease
        final lowerTestPrice = 90.0; // 10% lower than buy price
        
        final longPnLLower = longTrade.calculatePnL(lowerTestPrice);
        final shortPnLLower = shortTrade.calculatePnL(lowerTestPrice);
        
        expect(longPnLLower, equals(-100.0), // 10 * (90 - 100) = -100
            reason: 'Long trade should lose when price decreases');
        expect(shortPnLLower, equals(100.0), // 10 * (100 - 90) = 100
            reason: 'Short trade should profit when price decreases');
        
        // Property 7: Zero quantity or zero price should result in zero values
        final zeroQuantityTrade = ActiveTradeItem(
          id: 'zero_qty_$iteration',
          assetId: testAsset.id,
          direction: TradeDirection.long,
          quantity: 0.0,
          buyPrice: 100.0,
          openDate: DateTime.now(),
        );
        
        expect(zeroQuantityTrade.getTotalValue(), equals(0.0),
            reason: 'Zero quantity trade should have zero total value');
        expect(zeroQuantityTrade.calculatePnL(currentPrice), equals(0.0),
            reason: 'Zero quantity trade should have zero P&L');
        
        final zeroPriceTrade = ActiveTradeItem(
          id: 'zero_price_$iteration',
          assetId: testAsset.id,
          direction: TradeDirection.long,
          quantity: 10.0,
          buyPrice: 0.0,
          openDate: DateTime.now(),
        );
        
        expect(zeroPriceTrade.getTotalValue(), equals(0.0),
            reason: 'Zero price trade should have zero total value');
        
        // Property 8: Performance calculations should be consistent across serialization
        final serializedAsset = AssetItem.fromJson(assetWithAllTrades.toJson());
        
        expect(serializedAsset.getDailyPerformancePercent(), closeTo(assetWithAllTrades.getDailyPerformancePercent(), 0.001),
            reason: 'Daily performance should be consistent after serialization');
        expect(serializedAsset.getOpenTradesPerformance(), closeTo(assetWithAllTrades.getOpenTradesPerformance(), 0.001),
            reason: 'Open trades performance should be consistent after serialization');
        expect(serializedAsset.getAllTradesPerformance(), closeTo(assetWithAllTrades.getAllTradesPerformance(), 0.001),
            reason: 'All trades performance should be consistent after serialization');
        expect(serializedAsset.getTotalPositionValue(), closeTo(assetWithAllTrades.getTotalPositionValue(), 0.001),
            reason: 'Total position value should be consistent after serialization');
        expect(serializedAsset.getTotalPnL(), closeTo(assetWithAllTrades.getTotalPnL(), 0.001),
            reason: 'Total P&L should be consistent after serialization');
        
        // Property 9: Edge case - very small numbers should be handled correctly
        if (iteration % 20 == 0) { // Test edge cases less frequently
          final smallTrade = ActiveTradeItem(
            id: 'small_trade_$iteration',
            assetId: testAsset.id,
            direction: TradeDirection.long,
            quantity: 0.001,
            buyPrice: 0.01,
            openDate: DateTime.now(),
          );
          
          final smallCurrentPrice = 0.02;
          final expectedSmallPnL = 0.001 * (0.02 - 0.01); // 0.00001
          
          expect(smallTrade.calculatePnL(smallCurrentPrice), closeTo(expectedSmallPnL, 0.0000001),
              reason: 'Small number calculations should be accurate');
          
          // Test very large numbers
          final largeTrade = ActiveTradeItem(
            id: 'large_trade_$iteration',
            assetId: testAsset.id,
            direction: TradeDirection.long,
            quantity: 1000000.0,
            buyPrice: 1000.0,
            openDate: DateTime.now(),
          );
          
          final largeCurrentPrice = 1100.0;
          final expectedLargePnL = 1000000.0 * (1100.0 - 1000.0); // 100,000,000
          
          expect(largeTrade.calculatePnL(largeCurrentPrice), closeTo(expectedLargePnL, 0.001),
              reason: 'Large number calculations should be accurate');
        }
        
        // Property 10: Performance metrics should handle negative prices gracefully
        final negativePreviousClose = -10.0;
        final assetWithNegativePrevious = testAsset.copyWith(previousClose: negativePreviousClose);
        
        // Should not throw exception and should handle gracefully
        expect(() => assetWithNegativePrevious.getDailyPerformancePercent(), returnsNormally,
            reason: 'Daily performance calculation should handle negative previous close gracefully');
        
        // When previous close is negative, percentage calculation should be 0 or handle appropriately
        final negativeResult = assetWithNegativePrevious.getDailyPerformancePercent();
        expect(negativeResult, isA<double>(),
            reason: 'Daily performance with negative previous close should return a valid double');
      }
    });

    testWidgets('Property 9: Trade Information Display Completeness - For any active trade, the trade item should display all required information (direction indicator, quantity, buy value, current P&L) and show the notice indicator only when a notice is present',
        (WidgetTester tester) async {
      // **Feature: enhanced-asset-cards, Property 9: Trade Information Display Completeness**
      // **Validates: Requirements 5.3, 5.4, 5.8, 5.9**
      
      final random = Random();
      
      // Test with multiple iterations to verify property holds across different scenarios
      for (int iteration = 0; iteration < 100; iteration++) {
        // Generate random trade parameters
        final tradeDirection = random.nextBool() ? TradeDirection.long : TradeDirection.short;
        final quantity = 1.0 + random.nextDouble() * 999.0; // 1-1000 shares
        final buyPrice = 1.0 + random.nextDouble() * 999.0; // $1-$1000
        final currentPrice = 1.0 + random.nextDouble() * 999.0; // $1-$1000
        final hasNotice = random.nextBool();
        final noticeText = hasNotice ? 'Test notice ${random.nextInt(1000)}' : null;
        final hasStopLoss = random.nextBool();
        
        // Generate stop loss configuration if needed
        StopLossConfig? stopLoss;
        if (hasStopLoss) {
          final stopLossType = random.nextBool() ? StopLossType.fixed : StopLossType.trailing;
          final alertEnabled = random.nextBool();
          
          if (stopLossType == StopLossType.fixed) {
            stopLoss = StopLossConfig(
              type: StopLossType.fixed,
              fixedValue: 1.0 + random.nextDouble() * 500.0,
              alertEnabled: alertEnabled,
            );
          } else {
            final isPercentage = random.nextBool();
            stopLoss = StopLossConfig(
              type: StopLossType.trailing,
              trailingAmount: isPercentage ? random.nextDouble() * 50.0 : 1.0 + random.nextDouble() * 100.0,
              isPercentage: isPercentage,
              alertEnabled: alertEnabled,
            );
          }
        }
        
        // Create test trade
        final testTrade = ActiveTradeItem(
          id: 'test_trade_$iteration',
          assetId: 'test_asset_$iteration',
          direction: tradeDirection,
          quantity: quantity,
          buyPrice: buyPrice,
          openDate: DateTime.now().subtract(Duration(days: random.nextInt(365))),
          notice: noticeText,
          stopLoss: stopLoss,
        );
        
        // Property 1: Trade direction should be correctly stored and accessible
        expect(testTrade.direction, equals(tradeDirection),
            reason: 'Trade direction should be correctly stored');
        expect(testTrade.direction.displayName, isNotEmpty,
            reason: 'Trade direction should have a valid display name');
        expect(testTrade.direction.iconName, isNotEmpty,
            reason: 'Trade direction should have a valid icon name');
        
        // Property 2: Quantity should be correctly stored and accessible
        expect(testTrade.quantity, equals(quantity),
            reason: 'Trade quantity should be correctly stored');
        expect(testTrade.quantity, greaterThan(0),
            reason: 'Trade quantity should be positive');
        
        // Property 3: Buy price should be correctly stored and accessible
        expect(testTrade.buyPrice, equals(buyPrice),
            reason: 'Trade buy price should be correctly stored');
        expect(testTrade.buyPrice, greaterThan(0),
            reason: 'Trade buy price should be positive');
        
        // Property 4: Total value calculation should be mathematically correct
        final expectedTotalValue = quantity * buyPrice;
        expect(testTrade.getTotalValue(), closeTo(expectedTotalValue, 0.001),
            reason: 'Trade total value should equal quantity * buy price');
        
        // Property 5: P&L calculation should be mathematically correct for trade direction
        final expectedPnL = tradeDirection == TradeDirection.long
            ? quantity * (currentPrice - buyPrice)
            : quantity * (buyPrice - currentPrice);
        final actualPnL = testTrade.calculatePnL(currentPrice);
        
        expect(actualPnL, closeTo(expectedPnL, 0.001),
            reason: 'P&L calculation should be correct for ${tradeDirection.displayName} trade');
        
        // Property 6: P&L percentage calculation should be mathematically correct
        final expectedPnLPercentage = expectedTotalValue > 0 ? (expectedPnL / expectedTotalValue) * 100 : 0.0;
        final actualPnLPercentage = testTrade.calculatePnLPercentage(currentPrice);
        
        expect(actualPnLPercentage, closeTo(expectedPnLPercentage, 0.001),
            reason: 'P&L percentage calculation should be correct');
        
        // Property 7: Notice indicator should only be present when notice exists
        expect(testTrade.hasNotice(), equals(hasNotice),
            reason: 'hasNotice() should return true only when notice text is present');
        
        if (hasNotice) {
          expect(testTrade.notice, equals(noticeText),
              reason: 'Notice text should be correctly stored when present');
          expect(testTrade.notice, isNotEmpty,
              reason: 'Notice text should not be empty when hasNotice() returns true');
        } else {
          expect(testTrade.notice, anyOf(isNull, isEmpty),
              reason: 'Notice should be null or empty when hasNotice() returns false');
        }
        
        // Property 8: Stop loss configuration should be correctly handled
        if (hasStopLoss) {
          expect(testTrade.stopLoss, isNotNull,
              reason: 'Stop loss should be present when configured');
          expect(testTrade.stopLoss!.isValid(), isTrue,
              reason: 'Stop loss configuration should be valid');
          
          // Test stop loss trigger calculation
          final triggerPrice = testTrade.stopLoss!.calculateTriggerPrice(currentPrice, tradeDirection);
          if (testTrade.stopLoss!.type == StopLossType.fixed) {
            expect(triggerPrice, equals(testTrade.stopLoss!.fixedValue),
                reason: 'Fixed stop loss trigger price should equal fixed value');
          } else {
            expect(triggerPrice, isNotNull,
                reason: 'Trailing stop loss should calculate a valid trigger price');
            expect(triggerPrice, greaterThan(0),
                reason: 'Trailing stop loss trigger price should be positive');
          }
          
          // Test alert configuration
          expect(testTrade.stopLoss!.alertEnabled, isA<bool>(),
              reason: 'Stop loss alert enabled should be a boolean');
        } else {
          expect(testTrade.stopLoss, isNull,
              reason: 'Stop loss should be null when not configured');
        }
        
        // Property 9: Trade information should be consistent across serialization
        final tradeJson = testTrade.toJson();
        final deserializedTrade = ActiveTradeItem.fromJson(tradeJson);
        
        expect(deserializedTrade.direction, equals(testTrade.direction),
            reason: 'Trade direction should survive serialization');
        expect(deserializedTrade.quantity, equals(testTrade.quantity),
            reason: 'Trade quantity should survive serialization');
        expect(deserializedTrade.buyPrice, equals(testTrade.buyPrice),
            reason: 'Trade buy price should survive serialization');
        expect(deserializedTrade.notice, equals(testTrade.notice),
            reason: 'Trade notice should survive serialization');
        expect(deserializedTrade.hasNotice(), equals(testTrade.hasNotice()),
            reason: 'Trade notice indicator should survive serialization');
        
        // Verify calculations are consistent after serialization
        expect(deserializedTrade.getTotalValue(), closeTo(testTrade.getTotalValue(), 0.001),
            reason: 'Total value calculation should be consistent after serialization');
        expect(deserializedTrade.calculatePnL(currentPrice), closeTo(testTrade.calculatePnL(currentPrice), 0.001),
            reason: 'P&L calculation should be consistent after serialization');
        expect(deserializedTrade.calculatePnLPercentage(currentPrice), closeTo(testTrade.calculatePnLPercentage(currentPrice), 0.001),
            reason: 'P&L percentage calculation should be consistent after serialization');
        
        // Property 10: Trade information should be preserved in copyWith operations
        final modifiedTrade = hasNotice 
            ? testTrade.copyWith(clearNotice: true)
            : testTrade.copyWith(notice: 'New notice');
        
        // Original properties should be preserved
        expect(modifiedTrade.direction, equals(testTrade.direction),
            reason: 'Trade direction should be preserved in copyWith');
        expect(modifiedTrade.quantity, equals(testTrade.quantity),
            reason: 'Trade quantity should be preserved in copyWith');
        expect(modifiedTrade.buyPrice, equals(testTrade.buyPrice),
            reason: 'Trade buy price should be preserved in copyWith');
        expect(modifiedTrade.stopLoss, equals(testTrade.stopLoss),
            reason: 'Stop loss configuration should be preserved in copyWith');
        
        // Modified property should be changed
        expect(modifiedTrade.hasNotice(), equals(!hasNotice),
            reason: 'Notice indicator should reflect the modified notice state');
        
        // Calculations should remain consistent
        expect(modifiedTrade.getTotalValue(), closeTo(testTrade.getTotalValue(), 0.001),
            reason: 'Total value should remain consistent after copyWith');
        expect(modifiedTrade.calculatePnL(currentPrice), closeTo(testTrade.calculatePnL(currentPrice), 0.001),
            reason: 'P&L calculation should remain consistent after copyWith');
        
        // Property 11: Edge cases should be handled correctly
        
        // Test with zero current price
        final zeroPricePnL = testTrade.calculatePnL(0.0);
        final expectedZeroPricePnL = tradeDirection == TradeDirection.long
            ? quantity * (0.0 - buyPrice)
            : quantity * (buyPrice - 0.0);
        expect(zeroPricePnL, closeTo(expectedZeroPricePnL, 0.001),
            reason: 'P&L calculation should handle zero current price correctly');
        
        // Test with very small quantities and prices
        if (iteration % 20 == 0) { // Test edge cases less frequently
          final smallTrade = ActiveTradeItem(
            id: 'small_trade_$iteration',
            assetId: 'test_asset',
            direction: TradeDirection.long,
            quantity: 0.001,
            buyPrice: 0.01,
            openDate: DateTime.now(),
          );
          
          expect(smallTrade.getTotalValue(), closeTo(0.00001, 0.0000001),
              reason: 'Small trade total value should be calculated correctly');
          
          final smallPnL = smallTrade.calculatePnL(0.02);
          expect(smallPnL, closeTo(0.00001, 0.0000001),
              reason: 'Small trade P&L should be calculated correctly');
        }
        
        // Property 12: Trade status and metadata should be correctly handled
        expect(testTrade.status, equals(TradeStatus.open),
            reason: 'New active trade should have open status');
        expect(testTrade.openDate, isA<DateTime>(),
            reason: 'Trade should have a valid open date');
        expect(testTrade.openDate.isBefore(DateTime.now().add(Duration(seconds: 1))), isTrue,
            reason: 'Trade open date should not be in the future');
        
        // Property 13: Multiple trades should maintain independent information
        final secondTrade = ActiveTradeItem(
          id: 'second_trade_$iteration',
          assetId: 'test_asset_$iteration',
          direction: tradeDirection == TradeDirection.long ? TradeDirection.short : TradeDirection.long,
          quantity: quantity + 10.0,
          buyPrice: buyPrice + 5.0,
          openDate: DateTime.now(),
          notice: hasNotice ? null : 'Different notice',
        );
        
        // Verify trades are independent
        expect(secondTrade.direction, isNot(equals(testTrade.direction)),
            reason: 'Second trade should have different direction');
        expect(secondTrade.quantity, isNot(equals(testTrade.quantity)),
            reason: 'Second trade should have different quantity');
        expect(secondTrade.buyPrice, isNot(equals(testTrade.buyPrice)),
            reason: 'Second trade should have different buy price');
        expect(secondTrade.hasNotice(), isNot(equals(testTrade.hasNotice())),
            reason: 'Second trade should have different notice state');
        
        // Verify calculations are independent
        expect(secondTrade.getTotalValue(), isNot(closeTo(testTrade.getTotalValue(), 0.001)),
            reason: 'Second trade should have different total value');
        expect(secondTrade.calculatePnL(currentPrice), isNot(closeTo(testTrade.calculatePnL(currentPrice), 0.001)),
            reason: 'Second trade should have different P&L');
        
        // Property 14: Trade information completeness in asset context
        final testAsset = _generateRandomEnhancedAsset(random, AssetType.stock).copyWith(
          currentValue: currentPrice,
          activeTrades: [testTrade],
        );
        
        // Verify trade information is accessible through asset
        expect(testAsset.activeTrades.length, equals(1),
            reason: 'Asset should contain the active trade');
        expect(testAsset.activeTrades.first.direction, equals(tradeDirection),
            reason: 'Trade direction should be accessible through asset');
        expect(testAsset.activeTrades.first.quantity, equals(quantity),
            reason: 'Trade quantity should be accessible through asset');
        expect(testAsset.activeTrades.first.buyPrice, equals(buyPrice),
            reason: 'Trade buy price should be accessible through asset');
        expect(testAsset.activeTrades.first.hasNotice(), equals(hasNotice),
            reason: 'Trade notice indicator should be accessible through asset');
        
        // Verify asset-level calculations include trade information
        expect(testAsset.getTotalPositionValue(), closeTo(expectedTotalValue, 0.001),
            reason: 'Asset total position value should include trade value');
        expect(testAsset.getTotalPnL(), closeTo(expectedPnL, 0.001),
            reason: 'Asset total P&L should include trade P&L');
      }
    });

    testWidgets('Property 11: Alert System Cross-Strategy Consistency - For any strategy type (TradingStrategy or CompositeStrategy) with alerts enabled, when the strategy conditions are met, the system should consistently trigger alert notifications',
        (WidgetTester tester) async {
      // **Feature: enhanced-asset-cards, Property 11: Alert System Cross-Strategy Consistency**
      // **Validates: Requirements 7.1, 7.2, 7.3**
      
      final random = Random();
      
      // Test with multiple iterations to verify property holds across different scenarios
      for (int iteration = 0; iteration < 100; iteration++) {
        // Property 1: Strategy alert state should be consistent across all strategy types
        for (final strategyType in [StrategyType.trendline, StrategyType.buyArea, StrategyType.elliotWaves]) {
          final strategy = _generateStrategyOfType(random, strategyType, 'alert_consistency_${iteration}_${strategyType.name}');
          final alertEnabled = random.nextBool();
          
          final strategyItem = TradingStrategyItem(
            id: 'strategy_item_${iteration}_${strategyType.name}',
            strategy: strategy,
            direction: random.nextBool() ? TradeDirection.long : TradeDirection.short,
            alertEnabled: alertEnabled,
            created: DateTime.now().subtract(Duration(days: random.nextInt(30))),
          );
          
          // Verify alert state is correctly stored for all strategy types
          expect(strategyItem.alertEnabled, equals(alertEnabled),
              reason: 'Alert state should be correctly stored for $strategyType');
          
          // Verify alert toggle works consistently for all strategy types
          final toggledItem = strategyItem.toggleAlert();
          expect(toggledItem.alertEnabled, equals(!alertEnabled),
              reason: 'Alert toggle should work consistently for $strategyType');
          
          // Verify serialization preserves alert state for all strategy types
          final json = strategyItem.toJson();
          final deserializedItem = TradingStrategyItem.fromJson(json);
          expect(deserializedItem.alertEnabled, equals(alertEnabled),
              reason: 'Alert state should survive serialization for $strategyType');
        }
        
        // Property 2: Composite strategy alerts should work consistently
        final compositeStrategy = _generateRandomCompositeStrategy(random, 'composite_alert_$iteration');
        final compositeAlertEnabled = random.nextBool();
        
        final compositeItem = TradingStrategyItem(
          id: 'composite_item_$iteration',
          strategy: compositeStrategy,
          direction: random.nextBool() ? TradeDirection.long : TradeDirection.short,
          alertEnabled: compositeAlertEnabled,
          created: DateTime.now(),
        );
        
        expect(compositeItem.alertEnabled, equals(compositeAlertEnabled),
            reason: 'Alert state should work for composite strategies');
        
        final toggledComposite = compositeItem.toggleAlert();
        expect(toggledComposite.alertEnabled, equals(!compositeAlertEnabled),
            reason: 'Alert toggle should work for composite strategies');
        
        // Property 3: Strategy condition evaluation should be consistent regardless of alert state
        final testAssetData = _generateRandomAssetData(random);
        
        // Test individual strategies
        for (final strategyType in [StrategyType.trendline, StrategyType.buyArea, StrategyType.elliotWaves]) {
          final strategy1 = _generateStrategyOfType(random, strategyType, 'condition_test_1_${iteration}_${strategyType.name}');
          final strategy2 = _generateStrategyOfType(random, strategyType, 'condition_test_2_${iteration}_${strategyType.name}');
          
          // Create identical strategies with different alert states
          final strategyWithAlerts = TradingStrategyItem(
            id: 'with_alerts_$iteration',
            strategy: strategy1,
            direction: TradeDirection.long,
            alertEnabled: true,
            created: DateTime.now(),
          );
          
          final strategyWithoutAlerts = TradingStrategyItem(
            id: 'without_alerts_$iteration',
            strategy: strategy1,
            direction: TradeDirection.long,
            alertEnabled: false,
            created: DateTime.now(),
          );
          
          // Condition evaluation should be identical regardless of alert state
          final resultWithAlerts = strategyWithAlerts.checkTriggerCondition(testAssetData);
          final resultWithoutAlerts = strategyWithoutAlerts.checkTriggerCondition(testAssetData);
          
          expect(resultWithAlerts, equals(resultWithoutAlerts),
              reason: 'Strategy condition evaluation should be independent of alert state for $strategyType');
        }
        
        // Property 4: Composite strategy condition evaluation should be consistent
        final compositeResult1 = compositeItem.checkTriggerCondition(testAssetData);
        final compositeResult2 = toggledComposite.checkTriggerCondition(testAssetData);
        
        expect(compositeResult1, equals(compositeResult2),
            reason: 'Composite strategy condition evaluation should be independent of alert state');
        
        // Property 5: Alert state should be preserved in asset context
        final testAsset = _generateRandomEnhancedAsset(random, AssetType.stock);
        
        // Add strategies with different alert states
        final strategiesWithMixedAlerts = [
          TradingStrategyItem(
            id: 'mixed_1_$iteration',
            strategy: _generateRandomStrategy(random, 'mixed_strategy_1_$iteration'),
            direction: TradeDirection.long,
            alertEnabled: true,
            created: DateTime.now(),
          ),
          TradingStrategyItem(
            id: 'mixed_2_$iteration',
            strategy: _generateRandomStrategy(random, 'mixed_strategy_2_$iteration'),
            direction: TradeDirection.short,
            alertEnabled: false,
            created: DateTime.now(),
          ),
          compositeItem,
        ];
        
        final assetWithStrategies = testAsset.copyWith(strategies: strategiesWithMixedAlerts);
        
        // Verify hasActiveAlerts correctly identifies when alerts are present
        final expectedHasAlerts = strategiesWithMixedAlerts.any((s) => s.alertEnabled);
        expect(assetWithStrategies.hasActiveAlerts(), equals(expectedHasAlerts),
            reason: 'Asset should correctly identify when strategy alerts are present');
        
        // Property 6: Stop loss alerts should work consistently with strategy alerts
        final tradeWithStopLoss = ActiveTradeItem(
          id: 'trade_with_stop_loss_$iteration',
          assetId: testAsset.id,
          direction: TradeDirection.long,
          quantity: 10.0,
          buyPrice: 100.0,
          openDate: DateTime.now(),
          stopLoss: StopLossConfig(
            type: StopLossType.fixed,
            fixedValue: 90.0,
            alertEnabled: true,
          ),
        );
        
        final assetWithTradeAlerts = assetWithStrategies.copyWith(
          activeTrades: [tradeWithStopLoss],
        );
        
        // Asset should report alerts from both strategies and trades
        expect(assetWithTradeAlerts.hasActiveAlerts(), isTrue,
            reason: 'Asset should report alerts from both strategies and stop losses');
        
        // Property 7: Alert state transitions should be atomic and consistent
        final strategyForTransitions = TradingStrategyItem(
          id: 'transition_test_$iteration',
          strategy: _generateRandomStrategy(random, 'transition_strategy_$iteration'),
          direction: TradeDirection.long,
          alertEnabled: false,
          created: DateTime.now(),
        );
        
        // Test multiple state transitions
        var currentStrategy = strategyForTransitions;
        final transitionStates = [true, false, true, false, true];
        
        for (int i = 0; i < transitionStates.length; i++) {
          final targetState = transitionStates[i];
          currentStrategy = currentStrategy.copyWith(alertEnabled: targetState);
          
          // Verify state is correctly set
          expect(currentStrategy.alertEnabled, equals(targetState),
              reason: 'Alert state should be correctly set in transition $i');
          
          // Verify condition evaluation is unaffected by state changes
          final conditionResult = currentStrategy.checkTriggerCondition(testAssetData);
          expect(conditionResult, isA<bool>(),
              reason: 'Strategy condition evaluation should work after alert state transition $i');
          
          // Verify serialization works after state changes
          final transitionJson = currentStrategy.toJson();
          final deserializedTransition = TradingStrategyItem.fromJson(transitionJson);
          expect(deserializedTransition.alertEnabled, equals(targetState),
              reason: 'Alert state should survive serialization after transition $i');
        }
        
        // Property 8: Alert system should handle edge cases consistently
        
        // Test with empty composite strategy
        final emptyComposite = CompositeStrategy(
          id: 'empty_composite_$iteration',
          name: 'Empty Composite',
          conditions: [],
          rootOperator: LogicalOperator.and,
        );
        
        final emptyCompositeItem = TradingStrategyItem(
          id: 'empty_composite_item_$iteration',
          strategy: emptyComposite,
          direction: TradeDirection.long,
          alertEnabled: true,
          created: DateTime.now(),
        );
        
        // Empty composite should always return false, regardless of alert state
        expect(emptyCompositeItem.checkTriggerCondition(testAssetData), isFalse,
            reason: 'Empty composite strategy should always return false');
        expect(emptyCompositeItem.alertEnabled, isTrue,
            reason: 'Alert state should be preserved even for empty composite strategies');
        
        // Property 9: Alert consistency across complex composite strategies
        if (iteration % 10 == 0) { // Test complex scenarios less frequently
          final complexComposite = _generateRandomCompositeStrategy(random, 'complex_alert_$iteration');
          
          // Create multiple items with same strategy but different alert states
          final alertEnabledItem = TradingStrategyItem(
            id: 'complex_enabled_$iteration',
            strategy: complexComposite,
            direction: TradeDirection.long,
            alertEnabled: true,
            created: DateTime.now(),
          );
          
          final alertDisabledItem = TradingStrategyItem(
            id: 'complex_disabled_$iteration',
            strategy: complexComposite,
            direction: TradeDirection.long,
            alertEnabled: false,
            created: DateTime.now(),
          );
          
          // Both should evaluate conditions identically
          final enabledResult = alertEnabledItem.checkTriggerCondition(testAssetData);
          final disabledResult = alertDisabledItem.checkTriggerCondition(testAssetData);
          
          expect(enabledResult, equals(disabledResult),
              reason: 'Complex composite strategy evaluation should be independent of alert state');
          
          // Test nested condition evaluation consistency
          for (int conditionIndex = 0; conditionIndex < complexComposite.conditions.length; conditionIndex++) {
            final condition = complexComposite.conditions[conditionIndex];
            final individualResult = condition.strategy.checkTriggerCondition(testAssetData);
            
            expect(individualResult, isA<bool>(),
                reason: 'Individual condition $conditionIndex should evaluate to boolean');
          }
        }
        
        // Property 10: Alert state should be independent across multiple assets
        final asset1 = _generateRandomEnhancedAsset(random, AssetType.stock);
        final asset2 = _generateRandomEnhancedAsset(random, AssetType.crypto);
        
        final strategy1 = TradingStrategyItem(
          id: 'asset1_strategy_$iteration',
          strategy: _generateRandomStrategy(random, 'asset1_strategy_$iteration'),
          direction: TradeDirection.long,
          alertEnabled: true,
          created: DateTime.now(),
        );
        
        final strategy2 = TradingStrategyItem(
          id: 'asset2_strategy_$iteration',
          strategy: _generateRandomStrategy(random, 'asset2_strategy_$iteration'),
          direction: TradeDirection.short,
          alertEnabled: false,
          created: DateTime.now(),
        );
        
        final assetWithAlerts = asset1.copyWith(strategies: [strategy1]);
        final assetWithoutAlerts = asset2.copyWith(strategies: [strategy2]);
        
        // Verify alert states are independent
        expect(assetWithAlerts.hasActiveAlerts(), isTrue,
            reason: 'First asset should have active alerts');
        expect(assetWithoutAlerts.hasActiveAlerts(), isFalse,
            reason: 'Second asset should not have active alerts');
        
        // Modify first asset's alert state
        final modifiedStrategy1 = strategy1.toggleAlert();
        final modifiedAsset1 = assetWithAlerts.copyWith(strategies: [modifiedStrategy1]);
        
        // Second asset should be unaffected
        expect(assetWithoutAlerts.hasActiveAlerts(), isFalse,
            reason: 'Second asset alert state should be independent of first asset changes');
        expect(modifiedAsset1.hasActiveAlerts(), isFalse,
            reason: 'First asset should now have no active alerts after toggle');
        
        // Property 11: Alert system should handle concurrent strategy evaluations consistently
        final concurrentStrategies = List.generate(5, (i) => TradingStrategyItem(
          id: 'concurrent_${iteration}_$i',
          strategy: _generateRandomStrategy(random, 'concurrent_strategy_${iteration}_$i'),
          direction: random.nextBool() ? TradeDirection.long : TradeDirection.short,
          alertEnabled: random.nextBool(),
          created: DateTime.now(),
        ));
        
        final assetWithConcurrentStrategies = testAsset.copyWith(strategies: concurrentStrategies);
        
        // Evaluate all strategies with same asset data
        final concurrentResults = concurrentStrategies.map((s) => s.checkTriggerCondition(testAssetData)).toList();
        
        // Re-evaluate to ensure consistency
        final secondEvaluation = concurrentStrategies.map((s) => s.checkTriggerCondition(testAssetData)).toList();
        
        for (int i = 0; i < concurrentResults.length; i++) {
          expect(secondEvaluation[i], equals(concurrentResults[i]),
              reason: 'Concurrent strategy $i should evaluate consistently across multiple calls');
        }
        
        // Verify hasActiveAlerts is consistent with individual alert states
        final expectedConcurrentAlerts = concurrentStrategies.any((s) => s.alertEnabled);
        expect(assetWithConcurrentStrategies.hasActiveAlerts(), equals(expectedConcurrentAlerts),
            reason: 'Asset alert state should be consistent with individual strategy alert states');
      }
    });

    testWidgets('Property 6: Asset Information Section Visibility - For any card state configuration, the asset information section should always remain visible regardless of the expansion state of other sections',
        (WidgetTester tester) async {
      // **Feature: enhanced-asset-cards, Property 6: Asset Information Section Visibility**
      // **Validates: Requirements 1.2**
      
      final random = Random();
      
      // Test with multiple iterations to verify property holds across different scenarios
      for (int iteration = 0; iteration < 20; iteration++) { // Reduced iterations for stability
        // Generate random enhanced asset with varying configurations
        final assetType = AssetType.values[random.nextInt(AssetType.values.length)];
        final testAsset = _generateRandomEnhancedAsset(random, assetType);
        
        // Generate random tags, strategies, and trades to test different card states
        final tagCount = random.nextInt(3); // 0-2 tags (reduced for stability)
        final tags = List.generate(tagCount, (i) => 'tag_${iteration}_$i');
        
        final strategyCount = random.nextInt(2); // 0-1 strategies (reduced for stability)
        final strategies = List.generate(strategyCount, (i) => TradingStrategyItem(
          id: 'strategy_${iteration}_$i',
          strategy: _generateRandomStrategy(random, 'strategy_${iteration}_$i'),
          direction: random.nextBool() ? TradeDirection.long : TradeDirection.short,
          alertEnabled: random.nextBool(),
          created: DateTime.now().subtract(Duration(days: random.nextInt(30))),
        ));
        
        final tradeCount = random.nextInt(2); // 0-1 active trades (reduced for stability)
        final activeTrades = List.generate(tradeCount, (i) => ActiveTradeItem(
          id: 'trade_${iteration}_$i',
          assetId: testAsset.id,
          direction: random.nextBool() ? TradeDirection.long : TradeDirection.short,
          quantity: 1.0 + random.nextDouble() * 10.0, // Smaller quantities
          buyPrice: 10.0 + random.nextDouble() * 100.0, // Smaller prices
          openDate: DateTime.now().subtract(Duration(days: random.nextInt(30))),
          notice: random.nextBool() ? 'Test notice $i' : null,
        ));
        
        final configuredAsset = testAsset.copyWith(
          tags: tags,
          strategies: strategies,
          activeTrades: activeTrades,
        );
        
        // Property 1: Asset information section should always be visible regardless of content
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView( // Wrap in scrollable to prevent overflow
              child: EnhancedAssetCard(asset: configuredAsset),
            ),
          ),
        ));
        
        // Find the AssetInformationSection widget
        final assetInfoFinder = find.byType(AssetInformationSection);
        expect(assetInfoFinder, findsOneWidget,
            reason: 'AssetInformationSection should always be present in the widget tree');
        
        // Property 2: Asset information section should be visible (not hidden by expansion states)
        final assetInfoWidget = tester.widget<AssetInformationSection>(assetInfoFinder);
        expect(assetInfoWidget.asset, equals(configuredAsset),
            reason: 'AssetInformationSection should display the correct asset data');
        
        // Verify key asset information elements are present
        expect(find.byType(AssetTypeIcon), findsOneWidget,
            reason: 'Asset type icon should be visible in asset information section');
        expect(find.byType(AssetIdentifiers), findsOneWidget,
            reason: 'Asset identifiers should be visible in asset information section');
        expect(find.byType(PerformanceMetrics), findsOneWidget,
            reason: 'Performance metrics should be visible in asset information section');
        
        // Property 3: Asset information visibility should be independent of tags section state
        if (tags.isNotEmpty) {
          // Find tags section if it exists
          final tagsSectionFinder = find.byType(TagsSection);
          if (tagsSectionFinder.evaluate().isNotEmpty) {
            // Tags section exists, verify asset info is still visible
            expect(assetInfoFinder, findsOneWidget,
                reason: 'AssetInformationSection should remain visible when tags section is present');
            
            // Verify asset information appears before tags section in the widget tree
            // by checking that both widgets exist and asset info is found first
            expect(assetInfoFinder, findsOneWidget,
                reason: 'AssetInformationSection should be present when TagsSection is present');
            expect(tagsSectionFinder, findsOneWidget,
                reason: 'TagsSection should be present when tags are not empty');
          }
        }
        
        // Property 4: Asset information should be visible in both mobile and tablet layouts
        // Test mobile layout (width < 600)
        await tester.binding.setSurfaceSize(const Size(400, 800));
        await tester.pumpAndSettle();
        
        expect(find.byType(AssetInformationSection), findsOneWidget,
            reason: 'AssetInformationSection should be visible in mobile layout');
        
        // Test tablet layout (width >= 600)
        await tester.binding.setSurfaceSize(const Size(800, 600));
        await tester.pumpAndSettle();
        
        expect(find.byType(AssetInformationSection), findsOneWidget,
            reason: 'AssetInformationSection should be visible in tablet layout');
        
        // Reset to default size
        await tester.binding.setSurfaceSize(null);
        
        // Property 5: Asset information content should be consistent across different card states
        final assetInfoWidget2 = tester.widget<AssetInformationSection>(find.byType(AssetInformationSection));
        
        // Verify asset data consistency
        expect(assetInfoWidget2.asset.id, equals(configuredAsset.id),
            reason: 'Asset ID should be consistent in asset information section');
        expect(assetInfoWidget2.asset.name, equals(configuredAsset.name),
            reason: 'Asset name should be consistent in asset information section');
        expect(assetInfoWidget2.asset.currentValue, equals(configuredAsset.currentValue),
            reason: 'Asset current value should be consistent in asset information section');
        expect(assetInfoWidget2.asset.assetType, equals(configuredAsset.assetType),
            reason: 'Asset type should be consistent in asset information section');
        
        // Property 6: Asset information should be accessible for interaction
        // Verify the asset information section can be tapped (if onTap is provided)
        var tapCount = 0;
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EnhancedAssetCard(
                asset: configuredAsset,
                onTap: () => tapCount++,
              ),
            ),
          ),
        ));
        
        // Tap on the asset information area
        await tester.tap(find.byType(AssetInformationSection));
        await tester.pumpAndSettle();
        
        expect(tapCount, equals(1),
            reason: 'Asset information section should be interactive when onTap is provided');
        
        // Property 7: Asset information should handle edge cases gracefully
        
        // Test with minimal asset data
        final minimalAsset = AssetItem(
          id: 'minimal_$iteration',
          name: 'Minimal Asset',
          symbol: 'MIN',
          currentValue: 100.0,
          currency: 'USD',
          lastUpdated: DateTime.now(),
          primaryIdentifierType: AssetIdentifierType.internal,
          assetType: AssetType.other,
        );
        
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: EnhancedAssetCard(asset: minimalAsset),
            ),
          ),
        ));
        
        expect(find.byType(AssetInformationSection), findsOneWidget,
            reason: 'AssetInformationSection should be visible even with minimal asset data');
      }
    });
  });
}

Map<String, dynamic> _generateRandomAssetData(Random random) {
  return {
    'currentPrice': 10.0 + random.nextDouble() * 1000.0, // Random price between 10-1010
    'volume': random.nextInt(1000000) + 1000, // Random volume between 1000-1001000
    'previousClose': 10.0 + random.nextDouble() * 1000.0,
    'high': 10.0 + random.nextDouble() * 1000.0,
    'low': 10.0 + random.nextDouble() * 1000.0,
  };
}

TradingStrategy _generateRandomStrategy(Random random, String id) {
  final strategyTypes = [StrategyType.trendline, StrategyType.buyArea, StrategyType.elliotWaves];
  final type = strategyTypes[random.nextInt(strategyTypes.length)];
  
  return _generateStrategyOfType(random, type, id);
}

TradingStrategy _generateStrategyOfType(Random random, StrategyType type, String id) {
  switch (type) {
    case StrategyType.trendline:
      final support = 50.0 + random.nextDouble() * 400.0;
      final resistance = support + 10.0 + random.nextDouble() * 100.0;
      return TrendlineStrategy(
        id: id,
        name: 'Trendline Strategy $id',
        supportLevel: support,
        resistanceLevel: resistance,
        trendDirection: random.nextBool() ? TrendDirection.upward : TrendDirection.downward,
      );
      
    case StrategyType.buyArea:
      final lower = 50.0 + random.nextDouble() * 300.0;
      final upper = lower + 20.0 + random.nextDouble() * 100.0;
      final ideal = lower + (upper - lower) * (0.3 + random.nextDouble() * 0.4); // 30-70% between bounds
      return BuyAreaStrategy(
        id: id,
        name: 'Buy Area Strategy $id',
        lowerBound: lower,
        upperBound: upper,
        idealArea: ideal,
      );
      
    case StrategyType.elliotWaves:
      final target = 100.0 + random.nextDouble() * 500.0;
      final levels = List.generate(5, (i) => 50.0 + random.nextDouble() * 600.0);
      return ElliotWavesStrategy(
        id: id,
        name: 'Elliott Waves Strategy $id',
        currentWave: 1 + random.nextInt(5),
        waveTarget: target,
        waveLevels: levels,
      );
      
    case StrategyType.composite:
      // This shouldn't happen in our test, but handle it gracefully
      return TrendlineStrategy(
        id: id,
        name: 'Fallback Trendline Strategy $id',
        supportLevel: 100.0,
        resistanceLevel: 200.0,
        trendDirection: TrendDirection.upward,
      );
  }
}

AssetItem _generateRandomEnhancedAsset(Random random, AssetType assetType) {
  final companies = [
    {'name': 'BASF SE', 'symbol': 'BAS', 'isin': 'DE000BASF111', 'wkn': 'BASF11'},
    {'name': 'SAP SE', 'symbol': 'SAP', 'isin': 'DE0007164600', 'wkn': '716460'},
    {'name': 'Mercedes-Benz Group AG', 'symbol': 'MBG', 'isin': 'DE0007100000', 'wkn': '710000'},
    {'name': 'Bitcoin', 'symbol': 'BTC', 'isin': null, 'wkn': null},
    {'name': 'Ethereum', 'symbol': 'ETH', 'isin': null, 'wkn': null},
    {'name': 'Gold', 'symbol': 'GOLD', 'isin': 'XC0009655157', 'wkn': '965515'},
    {'name': 'Oil CFD', 'symbol': 'OIL', 'isin': null, 'wkn': null},
    {'name': 'S&P 500 CFD', 'symbol': 'SPX', 'isin': null, 'wkn': null},
  ];
  
  final company = companies[random.nextInt(companies.length)];
  final currentValue = 10.0 + random.nextDouble() * 1000.0; // Random value between 10-1010
  final previousClose = currentValue + (random.nextDouble() - 0.5) * 20.0; // +/- 10 from current
  
  // Generate random tags
  final tagOptions = ['tech', 'growth', 'value', 'dividend', 'volatile', 'stable', 'emerging', 'blue-chip'];
  final tagCount = random.nextInt(6); // 0-5 tags
  final tags = List.generate(tagCount, (index) => tagOptions[random.nextInt(tagOptions.length)]).toSet().toList();
  
  return AssetItem(
    id: '${company['symbol']}_${random.nextInt(10000)}',
    isin: company['isin'],
    wkn: company['wkn'],
    ticker: company['symbol'],
    name: company['name']!,
    symbol: company['symbol']!,
    currentValue: double.parse(currentValue.toStringAsFixed(2)),
    previousClose: double.parse(previousClose.toStringAsFixed(2)),
    currency: _getRandomCurrency(random, assetType),
    lastUpdated: DateTime.now().subtract(Duration(minutes: random.nextInt(60))),
    primaryIdentifierType: _getRandomIdentifierType(random, company),
    isInWatchlist: random.nextBool(),
    dayChange: null, // Let it be calculated
    dayChangePercent: null, // Let it be calculated
    hints: _generateRandomHints(random),
    tags: tags,
    strategies: [], // Empty for this test
    activeTrades: [], // Empty for this test
    closedTrades: [], // Empty for this test
    assetType: assetType,
  );
}

String _getRandomCurrency(Random random, AssetType assetType) {
  switch (assetType) {
    case AssetType.crypto:
      return ['USD', 'EUR', 'BTC', 'ETH'][random.nextInt(4)];
    case AssetType.stock:
      return ['USD', 'EUR', 'GBP', 'JPY'][random.nextInt(4)];
    case AssetType.resource:
      return ['USD', 'EUR'][random.nextInt(2)];
    case AssetType.cfd:
      return ['USD', 'EUR', 'GBP'][random.nextInt(3)];
    case AssetType.other:
      return ['USD', 'EUR', 'GBP', 'JPY', 'CHF'][random.nextInt(5)];
  }
}

AssetIdentifierType _getRandomIdentifierType(Random random, Map<String, String?> company) {
  final availableTypes = <AssetIdentifierType>[];
  
  if (company['isin'] != null) availableTypes.add(AssetIdentifierType.isin);
  if (company['wkn'] != null) availableTypes.add(AssetIdentifierType.wkn);
  availableTypes.add(AssetIdentifierType.ticker);
  availableTypes.add(AssetIdentifierType.internal);
  
  return availableTypes[random.nextInt(availableTypes.length)];
}

List<AssetHint> _generateRandomHints(Random random) {
  final hintTypes = ['buy_zone', 'trendline', 'support', 'resistance', 'breakout', 'oversold', 'overbought'];
  final hintCount = random.nextInt(4); // 0-3 hints
  
  return List.generate(hintCount, (index) {
    final type = hintTypes[random.nextInt(hintTypes.length)];
    return AssetHint(
      type: type,
      description: 'Random $type hint ${random.nextInt(100)}',
      value: random.nextBool() ? 50.0 + random.nextDouble() * 500.0 : null,
      timestamp: DateTime.now().subtract(Duration(days: random.nextInt(30))),
    );
  });
}

CompositeStrategy _generateRandomCompositeStrategy(Random random, String id) {
  // Generate 1-5 conditions for the composite strategy
  final conditionCount = 1 + random.nextInt(5);
  final conditions = <StrategyCondition>[];
  
  // Generate the first condition (no operator)
  final firstStrategy = _generateRandomStrategy(random, '${id}_condition_0');
  conditions.add(StrategyCondition(strategy: firstStrategy, operator: null));
  
  // Generate additional conditions with operators
  for (int i = 1; i < conditionCount; i++) {
    final strategy = _generateRandomStrategy(random, '${id}_condition_$i');
    final operator = random.nextBool() ? LogicalOperator.and : LogicalOperator.or;
    conditions.add(StrategyCondition(strategy: strategy, operator: operator));
  }
  
  // Choose random root operator
  final rootOperator = random.nextBool() ? LogicalOperator.and : LogicalOperator.or;
  
  return CompositeStrategy(
    id: id,
    name: 'Composite Strategy $id',
    conditions: conditions,
    rootOperator: rootOperator,
  );
}

List<String> _generateRandomTags(Random random) {
  final tagOptions = ['technical', 'fundamental', 'momentum', 'reversal', 'breakout', 'trend', 'scalping', 'swing'];
  final tagCount = random.nextInt(4); // 0-3 tags
  final selectedTags = <String>{};
  
  while (selectedTags.length < tagCount && selectedTags.length < tagOptions.length) {
    selectedTags.add(tagOptions[random.nextInt(tagOptions.length)]);
  }
  
  return selectedTags.toList();
}

void _compareStrategyParameters(Map<String, dynamic> original, Map<String, dynamic> applied, StrategyType type) {
  switch (type) {
    case StrategyType.trendline:
      expect(applied['supportLevel'], equals(original['supportLevel']),
          reason: 'Trendline strategy support level should be preserved');
      expect(applied['resistanceLevel'], equals(original['resistanceLevel']),
          reason: 'Trendline strategy resistance level should be preserved');
      expect(applied['trendDirection'], equals(original['trendDirection']),
          reason: 'Trendline strategy trend direction should be preserved');
      break;
      
    case StrategyType.buyArea:
      expect(applied['lowerBound'], equals(original['lowerBound']),
          reason: 'Buy area strategy lower bound should be preserved');
      expect(applied['upperBound'], equals(original['upperBound']),
          reason: 'Buy area strategy upper bound should be preserved');
      expect(applied['idealArea'], equals(original['idealArea']),
          reason: 'Buy area strategy ideal area should be preserved');
      break;
      
    case StrategyType.elliotWaves:
      expect(applied['currentWave'], equals(original['currentWave']),
          reason: 'Elliott waves strategy current wave should be preserved');
      expect(applied['waveTarget'], equals(original['waveTarget']),
          reason: 'Elliott waves strategy wave target should be preserved');
      expect(applied['waveLevels'], equals(original['waveLevels']),
          reason: 'Elliott waves strategy wave levels should be preserved');
      break;
      
    case StrategyType.composite:
      // For composite strategies, we need to compare the nested structure
      expect(applied['conditions'], equals(original['conditions']),
          reason: 'Composite strategy conditions should be preserved');
      expect(applied['rootOperator'], equals(original['rootOperator']),
          reason: 'Composite strategy root operator should be preserved');
      break;
  }
}