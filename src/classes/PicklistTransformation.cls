public with sharing class PicklistTransformation implements RecordsTransformationUtility {
    private Map<String, String> picklistMapping { get; set; }
    private String fieldName { get; set; }

    public PicklistTransformation(Map<String, String> transformationMapping, String field) {
        this.picklistMapping = transformationMapping == null ? new Map<String, String>() : transformationMapping;
        this.fieldName = field;
    }

    public SObject transform(SObject value) {
        String currentValue = String.valueOf(value.get(fieldName));
        if (picklistMapping.containsKey(currentValue)) {
            value.put(fieldName, picklistMapping.get(currentValue));
        }
        return value;
    }
}