// Helper class to track pending job applications and employer decisions
class ApplicationState {
  static int pendingApplications = 0;
  static int pendingPendingStatus = 0;
  static int pendingSuccessful = 0;
  static int pendingFailed = 0;

  // Called when employee swipes right on a job
  static void recordApplication() {
    pendingApplications++;
    pendingPendingStatus++;
  }

  // Called when employer makes a decision on a candidate
  static void recordEmployerDecision(bool accepted) {
    if (pendingPendingStatus > 0) {
      pendingPendingStatus--; // Decrease pending as decision is made
      
      if (accepted) {
        pendingSuccessful++; // Increase successful count
      } else {
        pendingFailed++; // Increase failed count
      }
    }
  }

  static void clearPending() {
    pendingApplications = 0;
    pendingPendingStatus = 0;
    pendingSuccessful = 0;
    pendingFailed = 0;
  }
}