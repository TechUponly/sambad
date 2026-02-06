String personaDescription(String persona) {
  switch (persona) {
    case 'Explorer':
      return 'Explorers are curious, love discovering new things, and often try out new features first.';
    case 'Connector':
      return 'Connectors thrive on building relationships and keeping the community engaged.';
    case 'Achiever':
      return 'Achievers are goal-oriented, active, and often top the leaderboards.';
    case 'Innovator':
      return 'Innovators bring new ideas, experiment, and inspire others with creativity.';
    default:
      return 'This user has a unique persona profile.';
  }
}
