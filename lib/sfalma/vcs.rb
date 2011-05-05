# If you read the source code you do the right thing! Read code and reach mastery!
# If you wonder what this is be prepared for a very neat feature! More to come soon!
module Sfalma
  class VCS
    def init
    end
    
    def to_hash
      vcs = Sfalma::vcs
      if vcs.size > 1
        return {}
      else
        return {
          'vcs' => {
            'type' => Sfalma::vcs
          }
        }
      end
    end
    
    def blame(filename)
    end
    
    def git(filename)
    end
    
    def hg(filename)
    end
    
    def svn(filename)
    end
    
  end
end

# 55b250f03f1ec3c83679f9f9a158cbe1da3c9796 7 12 1
# author Panagiotis Papadopoulos
# author-mail <panosjee@gmail.com>
# author-time 1294941201
# author-tz +0200
# committer Panagiotis Papadopoulos
# committer-mail <panosjee@gmail.com>
# committer-time 1294941201
# committer-tz +0200
# summary first commit