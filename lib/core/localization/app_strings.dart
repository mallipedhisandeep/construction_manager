class S {
  final bool tel;
  const S(this.tel);

  String get appTitle     => tel ? 'నిర్మాణ మేనేజర్'    : 'Construction Manager';
  String get welcome      => tel ? 'స్వాగతం'            : 'Welcome Back';
  String get signOut      => tel ? 'లాగ్అవుట్'          : 'Sign Out';
  String get modules      => tel ? 'విభాగాలు'           : 'Modules';
  String get language     => tel ? 'భాష'                : 'Language';

  // Nav modules
  String get attendance      => tel ? 'రోజువారీ హాజరు'        : 'Daily Attendance';
  String get workers         => tel ? 'కార్మికులు'             : 'Workers';
  String get sites           => tel ? 'సైట్లు'                : 'Sites';
  String get privateWorkers  => tel ? 'ప్రైవేట్ కార్మికులు'   : 'Private Workers';
  String get privateWork     => tel ? 'ప్రైవేట్ పని'          : 'Private Work';

  // Stats
  String get activeSites  => tel ? 'చురుకైన సైట్లు' : 'Active Sites';
  String get contractors  => tel ? 'కాంట్రాక్టర్లు'  : 'Contractors';

  // Actions
  String get save         => tel ? 'సేవ్ చేయి'     : 'Save';
  String get cancel       => tel ? 'రద్దు'          : 'Cancel';
  String get add          => tel ? 'జోడించు'        : 'Add';
  String get edit         => tel ? 'సవరించు'        : 'Edit';
  String get delete       => tel ? 'తొలగించు'       : 'Delete';
  String get search       => tel ? 'వెతకండి'        : 'Search';
  String get close        => tel ? 'మూసివేయి'       : 'Close';
  String get confirm      => tel ? 'నిర్ధారించు'    : 'Confirm';
  String get update       => tel ? 'అప్డేట్'        : 'Update';

  // Worker fields
  String get name          => tel ? 'పేరు'                    : 'Full Name';
  String get mobileNumber  => tel ? 'మొబైల్ నంబర్'           : 'Mobile Number';
  String get gender        => tel ? 'లింగం'                   : 'Gender';
  String get male          => tel ? 'పురుషుడు'               : 'Male';
  String get female        => tel ? 'స్త్రీ'                  : 'Female';
  String get state         => tel ? 'రాష్ట్రం'                : 'State';
  String get role          => tel ? 'పాత్ర'                   : 'Role';
  String get workType      => tel ? 'పని రకం'                 : 'Work Type';
  String get wageRates     => tel ? 'వేతన రేట్లు (₹)'        : 'Wage Rates (₹)';
  String get notes         => tel ? 'గమనికలు'                 : 'Notes';
  String get personalInfo  => tel ? 'వ్యక్తిగత వివరాలు'      : 'Personal Info';
  String get mason         => tel ? 'మేస్త్రీ'               : 'Mason';
  String get helper        => tel ? 'హెల్పర్'                 : 'Helper';
  String get centring      => tel ? 'సెంట్రింగ్'              : 'Centring';
  String get brickwork     => tel ? 'ఇటుక పని'               : 'Brickwork';

  // Worker actions
  String get addWorker    => tel ? 'కార్మికుని జోడించు'   : 'Add Worker';
  String get editWorker   => tel ? 'కార్మికుని సవరించు'  : 'Edit Worker';
  String get saveWorker   => tel ? 'కార్మికుని సేవ్ చేయి' : 'Save Worker';
  String get updateWorker => tel ? 'కార్మికుని అప్డేట్'   : 'Update Worker';
  String get deleteWorker => tel ? 'కార్మికుని తొలగించు'  : 'Delete Worker';
  String get searchWorkers => tel ? 'కార్మికులను వెతకండి' : 'Search workers...';

  // Site fields
  String get siteName     => tel ? 'సైటు పేరు'          : 'Site Name';
  String get location     => tel ? 'లొకేషన్'             : 'Location / Address';
  String get ownerName    => tel ? 'యజమాని పేరు'         : 'Owner Name';
  String get ownerPhone   => tel ? 'యజమాని ఫోన్'         : 'Owner Phone';
  String get startDate    => tel ? 'ప్రారంభ తేదీ'        : 'Start Date';
  String get budget       => tel ? 'బడ్జెట్ (₹)'         : 'Budget (₹)';
  String get numFloors    => tel ? 'అంతస్తుల సంఖ్య'      : 'Number of Floors';
  String get status       => tel ? 'స్థితి'               : 'Status';
  String get active       => tel ? 'చురుకు'               : 'Active';
  String get completed    => tel ? 'పూర్తి'               : 'Completed';
  String get addSite      => tel ? 'సైటు జోడించు'         : 'Add Site';
  String get editSite     => tel ? 'సైటు సవరించు'         : 'Edit Site';
  String get saveSite     => tel ? 'సైటు సేవ్ చేయి'       : 'Save Site';
  String get deleteSite   => tel ? 'సైటు తొలగించు'        : 'Delete Site';
  String get floorPlans   => tel ? 'అంతస్తు ప్లాన్లు'     : 'Floor Plans';
  String get agreements   => tel ? 'ఒప్పందాలు'            : 'Agreements';
  String get elevations   => tel ? 'ఎలివేషన్లు'           : 'Elevations';
  String get groundFloor  => tel ? 'గ్రౌండ్ ఫ్లోర్'       : 'Ground Floor';

  // Attendance
  String get shift        => tel ? 'షిఫ్ట్'                  : 'Attendance / Shift';
  String get absent       => tel ? 'గైర్హాజరు'               : 'Absent';
  String get siteWorked   => tel ? 'పని చేసిన సైటు'           : 'Site Worked';
  String get advanceGiven => tel ? 'ఇచ్చిన అడ్వాన్స్ (₹)'   : 'Advance Given (₹)';
  String get paymentMode  => tel ? 'చెల్లింపు పద్ధతి'         : 'Payment Mode';
  String get monthlySummary => tel ? 'నెలవారీ సారాంశం'       : 'Monthly Summary';
  String get daysWorked   => tel ? 'పని చేసిన రోజులు'         : 'Days Worked';
  String get totalEarned  => tel ? 'మొత్తం సంపాదించింది'      : 'Total Earned';
  String get totalAdvance => tel ? 'మొత్తం అడ్వాన్స్'         : 'Total Advance';
  String get openingBal   => tel ? 'ప్రారంభ బాకీ'            : 'Opening Balance';
  String get balance      => tel ? 'బాకీ'                     : 'Balance';
  String get toGive       => tel ? 'ఇవ్వాల్సిన బాకీ'         : 'Balance to give';
  String get toReceive    => tel ? 'తీసుకోవాల్సిన బాకీ'      : 'Balance to receive';
  String get settled      => tel ? 'క్లియర్ అయింది'           : 'All Settled';

  // Private Worker
  String get addContractor    => tel ? 'కాంట్రాక్టర్ జోడించు'   : 'Add Contractor';
  String get editContractor   => tel ? 'కాంట్రాక్టర్ సవరించు'  : 'Edit Contractor';
  String get saveContractor   => tel ? 'కాంట్రాక్టర్ సేవ్'      : 'Save Contractor';
  String get updateContractor => tel ? 'కాంట్రాక్టర్ అప్డేట్'  : 'Update Contractor';
  String get deleteWorkerQ    => tel ? 'కార్మికుని తొలగించాలా?' : 'Delete this worker?';
  String get toGiveWorker     => tel ? 'కార్మికుడికి ఇవ్వాలి'   : 'Owed to worker';
  String get toReceiveWorker  => tel ? 'కార్మికుడు ఇవ్వాలి'     : 'Worker owes you';
  String get addPayment       => tel ? 'చెల్లింపు జోడించు'       : 'Add Payment';
  String get paymentHistory   => tel ? 'చెల్లింపు చరిత్ర'        : 'Payment History';
  String get youToWorker      => tel ? 'మీరు → కార్మికుడు'       : 'You → Worker';
  String get workerToYou      => tel ? 'కార్మికుడు → మీరు'       : 'Worker → You';
  String get direction        => tel ? 'దిశ'                     : 'Direction';
  String get lastSite         => tel ? 'చివరి సైటు'              : 'Last Site';
  String get lastDate         => tel ? 'చివరి తేదీ'              : 'Last Date';

  // Private Work
  String get addWork          => tel ? 'పని జోడించు'             : 'Add Work Entry';
  String get updateWork       => tel ? 'పని అప్డేట్'             : 'Update Work Entry';
  String get priceCharged     => tel ? 'వసూలు ధర (₹)'           : 'Price Charged (₹)';
  String get amountPaid       => tel ? 'చెల్లించిన మొత్తం (₹)'  : 'Amount Paid (₹)';
  String get pendingBalance   => tel ? 'పెండింగ్ బాకీ'           : 'Total Pending';
  String get allSettled       => tel ? 'అన్నీ క్లియర్ ✓'         : 'All Settled ✓';
  String get deleteWork       => tel ? 'పనిని తొలగించు'          : 'Delete Work Entry';

  // Validation/Messages
  String get required      => tel ? 'అవసరం'                       : 'Required';
  String get invalidPhone  => tel ? '10 అంకెల నంబర్ నమోదు చేయండి' : 'Enter valid 10-digit number';
  String get workerAdded   => tel ? 'కార్మికుడు జోడించబడ్డారు!'   : 'Worker added!';
  String get workerUpdated => tel ? 'కార్మికుడు అప్డేట్ అయ్యారు!' : 'Worker updated!';
  String get siteAdded     => tel ? 'సైటు జోడించబడింది!'          : 'Site added!';
  String get siteUpdated   => tel ? 'సైటు అప్డేట్ అయింది!'        : 'Site updated!';
  String get savedOk       => tel ? 'విజయంగా సేవ్ అయింది!'        : 'Saved successfully!';
  String get attSaved      => tel ? 'హాజరు సేవ్ అయింది!'          : 'Attendance saved!';
  String get paymentAdded  => tel ? 'చెల్లింపు జోడించబడింది!'      : 'Payment added!';
  String get errorPrefix   => tel ? 'లోపం: '                       : 'Error: ';

  // Empty states
  String get noWorkers     => tel ? 'కార్మికులు కనుగొనబడలేదు'    : 'No workers found';
  String get noSites       => tel ? 'సైట్లు కనుగొనబడలేదు'        : 'No sites found';
  String get noContractors => tel ? 'కాంట్రాక్టర్లు కనుగొనబడలేదు' : 'No contractors found';
  String get noWork        => tel ? 'పని వివరాలు కనుగొనబడలేదు'    : 'No work entries found';
  String get noPayments    => tel ? 'చెల్లింపు చరిత్ర లేదు'        : 'No payment history';
  String get notMarked     => tel ? 'గుర్తించబడలేదు'               : 'Not marked';

  // Sign in page
  String get signIn        => tel ? 'లాగిన్ చేయి'         : 'Sign In';
  String get email         => tel ? 'ఇమెయిల్'              : 'Email';
  String get password      => tel ? 'పాస్‌వర్డ్'            : 'Password';
  String get welcomeBack   => tel ? 'తిరిగి స్వాగతం'       : 'Welcome Back';
  String get enterCreds    => tel ? 'మీ వివరాలు నమోదు చేయండి' : 'Enter your credentials';
  String get wrongCreds    => tel ? 'తప్పు ఇమెయిల్ లేదా పాస్‌వర్డ్' : 'Wrong email or password.';
}
