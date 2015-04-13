function computeEDFxPerformance( test_hypnogram, ref_hypnogram, classification_mode )
%computeEDFxPerformance Prints algorithm performance by comparing against a
%reference hypnogram
%   computeEDFxPerformance(test_hypnogram, ref_hypnogram, classification_mode)
%   compares the test_hypnogram against ref_hypnogram based on either AASM
%   or RK classification_mode and prints out the confusion matrix of
%   results as well as the sensitivity and selectivity of each sleep stage


% Error checking for hypnogram sizes
if size(test_hypnogram) ~= size(ref_hypnogram)
    error('Incorrect test and reference hypnogram lengths')
end

% Error checking for classification mode
if ~(strcmp(classification_mode, 'RK') || strcmp(classification_mode, 'AASM'))
    error('Unknown classification mode: use RK or AASM as options')
end

% Error checking for unknown labels
u_ref  = unique(ref_hypnogram);
u_test = unique(test_hypnogram);
check_member = ismember(u_test, u_ref);
if sum(check_member==0)
    error('Unknown labels in the test hypnogram')
end

% Labels to use for RK or AASM
RK_labels    = ['W'; '1'; '2'; '3'; '4'; 'R'; 'M'; '?'];
AASM_labels  = ['W'; '1'; '2'; '3'; 'R'; '?'];

% Overall accuracy of the system 
true_positives_total  = sum(test_hypnogram==ref_hypnogram);
false_positives_total = sum(test_hypnogram~=ref_hypnogram);
overall_accuracy = true_positives_total/length(test_hypnogram);

% Print summary of overall results
fprintf('\n\nClassification Mode: %s\n', classification_mode);
fprintf('\n---SUMMARY OF RESULTS---\n\n')
fprintf('Total number of epochs           : %d\n', length(ref_hypnogram));
fprintf('Total number of true positives   : %d\n', true_positives_total);
fprintf('Total number of false positives  : %d\n', false_positives_total);
fprintf('Overall classification accuracy  : %f\n', overall_accuracy);

% Print the confusion matrix of results
total_text= 'Total';

% Print the headers
fprintf('\n---CONFUSION MATRIX---\n\n');
if strcmp(classification_mode, 'RK')
    fprintf('Ref/Test\t%5s\t%5s\t%5s\t%5s\t%5s\t%5s\t%5s\t%5s\t%5s\n', RK_labels(1), RK_labels(2), RK_labels(3), RK_labels(4), RK_labels(5), RK_labels(6), RK_labels(7), RK_labels(8), total_text)
    labels_to_use = RK_labels;
else
    fprintf('Ref/Test\t%5s\t%5s\t%5s\t%5s\t%5s\t%5s\n', AASM_labels(1), AASM_labels(2), AASM_labels(3), AASM_labels(4), AASM_labels(5), total_text);
    labels_to_use = AASM_labels;
end

% Print results of each stage for the confusion matrix
for i=1:length(labels_to_use)
    formatted_output = sprintf('%-8s', ['    ' labels_to_use(i)]);
    result = 0;
    for j=1:length(labels_to_use)
        result = sum(ref_hypnogram==labels_to_use(i) & test_hypnogram==labels_to_use(j));
        formatted_output = [formatted_output sprintf('\t%5d', result)];
    end
    formatted_output = [formatted_output sprintf('\t%5d\n', sum(ref_hypnogram==labels_to_use(i)))];
    fprintf(formatted_output);
end

% Print the final line of results
formatted_output = sprintf('%-8s', ['  ' total_text]);
for j=1:length(labels_to_use)
    formatted_output = [formatted_output sprintf('\t%5d', sum(test_hypnogram==labels_to_use(j)))];
end
formatted_output = [formatted_output sprintf('\t%5d\n', length(ref_hypnogram))];
fprintf(formatted_output);

% Print the sensitivity and selectivity of each sleepstage
fprintf('\n---DETAILED RESULTS FOR EACH STAGE---\n\n');
fprintf('Stage\tSensitivity\tSelectivity\n');
for i=1:length(labels_to_use)
    sensitivity = sum(ref_hypnogram==labels_to_use(i) & test_hypnogram==labels_to_use(i))/sum(ref_hypnogram==labels_to_use(i));
    selectivity = sum(ref_hypnogram==labels_to_use(i) & test_hypnogram==labels_to_use(i))/sum(test_hypnogram==labels_to_use(i));
    fprintf('  %-5s\t%11f\t%11f\n', labels_to_use(i), sensitivity, selectivity);
end


end

